class Mhc::ProviderPersonalInformationsController < ApplicationController
  before_action :set_provider_personal_information, only: [:update]

  def update
    @provider_personal_information.assign_attributes(provider_personal_information_params)

    if params[:page_tab].present?
      page_tab = params[:page_tab]
    else
      page_tab = 'practitioner_info'
    end

    if @provider_personal_information.save
      redirect_to mhc_verification_platform_path(page_tab: page_tab,id: params[:provider_personal_information][:provider_attest_id]), notice: 'Practice information saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: page_tab,id: params[:provider_personal_information][:provider_attest_id]), alert: 'Failed to save practice information.'
    end
  end

  def verify_npi
    npi = params[:number]
    uri = URI("https://npiregistry.cms.hhs.gov/api/?number=#{npi}&version=2.1")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
  
    if json["results"] && json["results"].any?
      render json: { status: "match" }
    else
      render json: { status: "no_match" }
    end
  rescue => e
    render json: { status: "error", message: e.message }, status: 500
  end

  private

  def set_provider_personal_information
    @provider_personal_information = ProviderPersonalInformation.find_by(provider_attest_id: params[:provider_personal_information][:provider_attest_id])
  end

  # Strong parameters for security
  def provider_personal_information_params
    params.require(:provider_personal_information).permit(
      :id, :caqh_provider_id, :provider_attest_id, :caqh_provider_attest_id, :last_name, :first_name,
      :middle_name, :suffix, :primary_practice_state, :other_name_flag, :birth_date, :us_eligible_flag,
      :ssn, :nid, :dea_flag, :cds_flag, :upin, :upin_flag, :npi_flag, :npi, :medicare_provider_flag,
      :medicaid_provider_flag, :other_graduate_education_flag, :fellowship_training_flag, :teaching_appointment_flag,
      :secondary_specialty_flag, :other_specialty_flag, :hospital_privilege_flag, :hospital_admitting_arrangements,
      :work_history_gap_flag, :active_military_flag, :citizenship_status, :visa_number, :federal_employee_id,
      :no_malpractice_claims_flag, :application_type, :ecfmg_flag, :ecfmg_number, :ecfmg_issue_date,
      :hospital_based_flag, :email_address, :visa_type, :visa_status, :birth_city, :birth_state,
      :tax_id, :spouse_last_name, :spouse_first_name, :other_correspondence_address,
      :emergency_contact_last_name, :emergency_contact_first_name, :emergency_contact_middle_name,
      :emergency_contact_phone, :pager_beeper_number, :answering_service_phone_number, :cell_phone_number,
      :pager_beeper_digital_flag, :visa_expiration_date, :ethnicity_description, :visa_issue_date,
      :ecfmg_expiration_date, :show_on_tickler, :work_permit_status, :spouse_middle_name,
      :state_residence_date, :citizenship_country_country_name, :marital_status_marital_status_description,
      :gender_gender_description, :birth_country_country_name, :correspondence_address_type_correspondence_address_type_descrip,
      :provider_type_provider_type_abbreviation, :graduate_type_graduate_type_description,
      :nid_country_country_name, :attest_date, :plan_provider_id, :last_recredential_date, :next_recredential_date,
      :npi_verification_status,
      provider_personal_information_credentialing_contact_attributes: [:id, :contact_method,
      :firstname, :middlename, :lastname, :title, :address, :suffix, :phone_number, :fax, :email, :suite, :address2,
      :city, :county, :state, :zip, :country],
      provider_personal_information_confidential_contact_attributes: [:id, :contact_method,
      :firstname, :middlename, :lastname, :title, :address, :suffix, :phone_number, :fax, :email, :suite, :address2,
      :city, :county, :state, :zip, :country])
  end
end
