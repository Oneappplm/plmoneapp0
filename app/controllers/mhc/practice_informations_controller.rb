class Mhc::PracticeInformationsController < ApplicationController
  def index
    @practice_informations = PracticeInformation.all
  end

  def create
    @practice_information = PracticeInformation.new(practice_information_params)

    if @practice_information.save
      redirect_to mhc_verification_platform_path(page_tab: 'practice_info',id: params[:practice_information][:provider_attest_id]), notice: 'Practice information saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'add_practice_info',id: params[:practice_information][:provider_attest_id]), alert: 'Failed to save practice information.'
    end
  end

  private

  # Strong parameters for security
  def practice_information_params
    params.require(:practice_information).permit(
      :caqh_provider_attest_id, :provider_attest_id, :practice_name, :address, :address2, :city,
      :state, :zip, :ext_zip, :county, :phone_number, :after_hours_phone_number, :fax_number,
      :email_address, :start_date, :end_date, :correspondence_flag,
      :partners_flag, :other_associates_flag, :currently_practicing_flag,
      :coverage24x7_flag, :practice_limitation_flag, :ada_approved_flag,
      :minority_business_flag, :interpreter_available_flag, :medicare_number,
      :medicaid_number, :epsdt_number, :practice_organization_type,
      :phone_number2, :patient_appointment_phone_number,
      :answering_service_phone_number, :pager_beeper_number,
      :w9_practice_name, :practice_intention_explanation,
      :list_in_directory_flag, :in_practice_flag, :epsdt_certified_flag,
      :electronic_billing_flag, :emergency_phone_number,
      :practice_description, :patients_enrolled, :patient_visits,
      :appointments_per_hour, :average_waiting_time, :call_response_time,
      :bwc_number, :workers_compensation_risk_number, :ownership_description,
      :emergency_procedure, :npi, :practice_type_description,
      :service_type_description, :department_name, :cell_phone_number,
      :pager_beeper_number2, :phone_extension,
      :patient_appointment_phone_extension, :answering_service_phone_extension
    )
  end
end
