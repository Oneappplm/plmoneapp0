# frozen_string_literal: true

module Webscrapers
  class SsnVerificationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_provider, only: :auto_verify
    before_action :set_verification, only: :report

    def auto_verify
      verification =
        Ssa::ProviderVerificationService.new(
          provider: @provider,
          verified_by: current_user
        ).call

      if verification.error?
        render json: {
          success: false,
          status: verification.status,
          message: verification.error_message
        }, status: :unprocessable_entity

        return
      end

      render json: {
        success: true,
        status: verification.status,
        message: verification_message(verification),
        verification_id: verification.id,

        ssn_matched: verification.ssn_matched,
        first_name_matched: verification.first_name_matched,
        middle_name_matched: verification.middle_name_matched,
        last_name_matched: verification.last_name_matched,
        date_of_birth_matched: verification.date_of_birth_matched,

        death_date: verification.death_date,
        matched_record_count: verification.matched_record_count,

        dmf_version: verification.dmf_file_version&.id,
        dmf_publication_date:
          verification.dmf_file_version&.publication_date,

        pdf_url: report_webscrapers_ssn_verification_path(
          verification
        )
      }
    end

    def report
      if @verification.report_pdf.blank?
        render plain: "SSA verification report is not available.",
               status: :not_found
        return
      end

      redirect_to(
        @verification.report_pdf.url,
        allow_other_host: true
      )
    end

    private

    def set_provider
      @provider = ProviderPersonalInformation.find(
        params.require(:provider_personal_information_id)
      )
    end

    def set_verification
      @verification = ProviderSsnVerification.find(params[:id])
    end

    def verification_message(verification)
      case verification.status
      when "matched"
        "Death Master match found for this provider."
      when "not_matched"
        "No Death Master match was found for this provider."
      when "review_required"
        "A Death Master record was found, but manual review is required."
      else
        verification.display_status
      end
    end
  end
end