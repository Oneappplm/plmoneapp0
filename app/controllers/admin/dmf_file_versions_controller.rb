# frozen_string_literal: true

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

      @versions =
        DmfFileVersion.latest_first.limit(50)
    end

    def new
      @dmf_file_version =
        DmfFileVersion.new
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
        id: @dmf_file_version.id,
        status: @dmf_file_version.status,
        active: @dmf_file_version.active,
        row_count: @dmf_file_version.row_count,
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
  end
end