# frozen_string_literal: true

require "aws-sdk-s3"
require "securerandom"

module Admin
  class DmfFileVersionsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_dmf_file_version,
                  only: %i[
                    show
                    start_import
                    status
                  ]

    def index
      @current_version = DmfFileVersion.current
      @versions = DmfFileVersion.latest_first.limit(50)
    end

    def new
      @dmf_file_version = DmfFileVersion.new
    end

    def create
      @dmf_file_version =
        DmfFileVersion.new(
          dmf_file_version_params
        )

      if @dmf_file_version.save
        redirect_to(
          admin_dmf_file_version_path(
            @dmf_file_version
          ),
          notice:
            "DMF artifact registered successfully."
        )
      else
        render :new,
               status: :unprocessable_entity
      end
    end

    # ---------------------------------------------------------
    # Check duplicate BEFORE uploading file to IDrive
    # ---------------------------------------------------------
    def check_duplicate
      sha256 = params[:sha256].to_s.downcase

      unless sha256.match?(/\A[a-f0-9]{64}\z/)
        render json: {
          success: false,
          message: "Invalid SHA256 checksum."
        }, status: :unprocessable_entity

        return
      end

      existing =
        DmfFileVersion.find_by(
          sha256: sha256
        )

      if existing.present?
        render json: {
          success: true,
          duplicate: true,
          message:
            "This DMF file has already been uploaded " \
            "as Version ##{existing.id}.",
          version_id: existing.id,
          source_filename: existing.source_filename,
          publication_date: existing.publication_date,
          row_count: existing.row_count,
          status: existing.status,
          active: existing.active,
          redirect_url:
            admin_dmf_file_version_path(existing)
        }

        return
      end

      render json: {
        success: true,
        duplicate: false
      }
    end

    # ---------------------------------------------------------
    # Generate signed IDrive upload URL
    # ---------------------------------------------------------
    def presign_upload
      filename =
        params[:filename].to_s

      content_type =
        params[:content_type].presence ||
        "application/gzip"

      unless valid_dmf_filename?(filename)
        render json: {
          success: false,
          message:
            "Only .tsv.gz DMF files are allowed."
        }, status: :unprocessable_entity

        return
      end

      object_key =
        build_artifact_key(filename)

      object =
        s3_resource
          .bucket(storage_bucket)
          .object(object_key)

      presigned_url =
        object.presigned_url(
          :put,
          expires_in: 3600,
          content_type: content_type
        )

      render json: {
        success: true,
        url: presigned_url,
        key: object_key
      }

    rescue StandardError => error
      Rails.logger.error(
        "[DMF UPLOAD] presign failed " \
        "#{error.class}: #{error.message}"
      )

      render json: {
        success: false,
        message: error.message
      }, status: :internal_server_error
    end

    # ---------------------------------------------------------
    # Register uploaded file and queue import
    # ---------------------------------------------------------
    def register_upload
      filename =
        params[:filename].to_s

      artifact_key =
        params[:artifact_key].to_s

      publication_date =
        params[:publication_date]

      sha256 =
        params[:sha256].to_s.downcase

      unless valid_dmf_filename?(filename)
        render json: {
          success: false,
          message: "Invalid DMF filename."
        }, status: :unprocessable_entity

        return
      end

      unless valid_artifact_key?(artifact_key)
        render json: {
          success: false,
          message: "Invalid DMF artifact key."
        }, status: :unprocessable_entity

        return
      end

      unless sha256.match?(/\A[a-f0-9]{64}\z/)
        render json: {
          success: false,
          message: "Invalid SHA256 checksum."
        }, status: :unprocessable_entity

        return
      end

      #
      # Final server-side duplicate protection.
      #
      existing =
        DmfFileVersion.find_by(
          sha256: sha256
        )

      if existing.present?
        delete_unregistered_artifact(artifact_key)

        render json: {
          success: false,
          duplicate: true,
          message:
            "This DMF file has already been uploaded " \
            "as Version ##{existing.id}.",
          version_id: existing.id,
          source_filename: existing.source_filename,
          publication_date: existing.publication_date,
          row_count: existing.row_count,
          status: existing.status,
          active: existing.active,
          redirect_url:
            admin_dmf_file_version_path(existing)
        }, status: :conflict

        return
      end

      unless artifact_exists?(artifact_key)
        render json: {
          success: false,
          message:
            "Uploaded DMF artifact could not be found."
        }, status: :unprocessable_entity

        return
      end

      version =
        DmfFileVersion.create!(
          source_filename: filename,
          artifact_key: artifact_key,
          sha256: sha256,
          publication_date: publication_date,
          status: "pending",
          active: false
        )

      DmfImportJob.perform_later(
        version.id
      )

      render json: {
        success: true,
        duplicate: false,
        version_id: version.id,
        redirect_url:
          admin_dmf_file_version_path(version)
      }

    rescue ActiveRecord::RecordNotUnique
      existing =
        DmfFileVersion.find_by(
          sha256: sha256
        )

      delete_unregistered_artifact(
        artifact_key
      )

      render json: {
        success: false,
        duplicate: true,
        message:
          existing.present? ?
            "This DMF file has already been uploaded " \
            "as Version ##{existing.id}." :
            "This DMF file has already been uploaded.",
        version_id: existing&.id,
        source_filename:
          existing&.source_filename,
        publication_date:
          existing&.publication_date,
        row_count:
          existing&.row_count,
        status:
          existing&.status,
        active:
          existing&.active,
        redirect_url:
          existing.present? ?
            admin_dmf_file_version_path(existing) :
            nil
      }, status: :conflict

    rescue ActiveRecord::RecordInvalid => error
      delete_unregistered_artifact(
        artifact_key
      )

      render json: {
        success: false,
        message:
          error.record.errors.full_messages.join(", ")
      }, status: :unprocessable_entity

    rescue StandardError => error
      Rails.logger.error(
        "[DMF UPLOAD] register failed " \
        "#{error.class}: #{error.message}"
      )

      render json: {
        success: false,
        message: error.message
      }, status: :internal_server_error
    end

    def show
    end

    def start_import
      unless @dmf_file_version.status == "pending"
        redirect_to(
          admin_dmf_file_version_path(
            @dmf_file_version
          ),
          alert:
            "This DMF version cannot currently be imported."
        )

        return
      end

      DmfImportJob.perform_later(
        @dmf_file_version.id
      )

      redirect_to(
        admin_dmf_file_version_path(
          @dmf_file_version
        ),
        notice:
          "DMF import has been queued."
      )
    end

    def status
      render json: {
        id:
          @dmf_file_version.id,
        status:
          @dmf_file_version.status,
        active:
          @dmf_file_version.active,
        row_count:
          @dmf_file_version.row_count,
        publication_date:
          @dmf_file_version.publication_date,
        import_started_at:
          @dmf_file_version.import_started_at,
        import_completed_at:
          @dmf_file_version.import_completed_at,
        error_message:
          @dmf_file_version.error_message
      }
    end

    private

    def set_dmf_file_version
      @dmf_file_version =
        DmfFileVersion.find(params[:id])
    end

    def delete_unregistered_artifact(key)
      return if key.blank?
      return unless valid_artifact_key?(key)

      referenced =
        DmfFileVersion.exists?(
          artifact_key: key
        )

      return if referenced

      object =
        s3_resource
          .bucket(storage_bucket)
          .object(key)

      return unless object.exists?

      object.delete

      Rails.logger.info(
        "[DMF UPLOAD] Deleted unregistered artifact " \
        "key=#{key.inspect}"
      )
    rescue StandardError => error
      Rails.logger.warn(
        "[DMF UPLOAD] Unable to delete unregistered artifact " \
        "key=#{key.inspect} " \
        "#{error.class}: #{error.message}"
      )
    end

    def dmf_file_version_params
      params
        .require(:dmf_file_version)
        .permit(
          :source_filename,
          :artifact_key,
          :sha256,
          :publication_date
        )
    end

    def s3_resource
      @s3_resource ||=
        Aws::S3::Resource.new(
          region:
            ENV.fetch(
              "AWS_REGION",
              "us-west-4"
            ),

          credentials:
            Aws::Credentials.new(
              ENV.fetch("AWS_ACCESS_KEY_ID"),
              ENV.fetch("AWS_SECRET_ACCESS_KEY")
            ),

          endpoint:
            ENV.fetch(
              "AWS_ENDPOINT",
              "https://s3.us-west-4.idrivee2.com"
            ),

          force_path_style: true
        )
    end

    def storage_bucket
      ENV["AWS_S3_BUCKET"].presence ||
        ENV.fetch("AWS_BUCKET")
    end

    def valid_dmf_filename?(filename)
      filename
        .to_s
        .downcase
        .end_with?(".tsv.gz")
    end

    def valid_sha256?(sha256)
      sha256.match?(
        /\A[a-f0-9]{64}\z/
      )
    end

    def valid_artifact_key?(key)
      key.start_with?(
        "uploads/death_master_file/"
      )
    end

    def build_artifact_key(filename)
      safe_name =
        filename.gsub(
          /[^a-zA-Z0-9.\-_]/,
          "_"
        )

      timestamp =
        Time.current.strftime(
          "%Y%m%d%H%M%S"
        )

      uuid =
        SecureRandom.uuid

      "uploads/death_master_file/" \
        "#{timestamp}-#{uuid}-#{safe_name}"
    end

    def artifact_exists?(key)
      s3_resource
        .bucket(storage_bucket)
        .object(key)
        .exists?
    end
  end
end