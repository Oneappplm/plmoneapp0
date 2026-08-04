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
        pdf_url: report_webscrapers_ssn_verification_path(
          verification
        )
      }
    end

    def report
      unless @verification.report_pdf.attached?
        render plain: "SSA verification report is not available.",
               status: :not_found
        return
      end

      redirect_to(
        rails_blob_url(
          @verification.report_pdf,
          disposition: "inline"
        ),
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
        "SSA Death Master record matched."
      when "not_matched"
        "No SSA Death Master record was found."
      when "review_required"
        "A Death Master record was found, but manual review is required."
      else
        verification.display_status
      end
    end
  end
end