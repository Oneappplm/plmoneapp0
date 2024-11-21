class Mhc::ProviderEducationsController < ApplicationController
  before_action :set_provider_education, only: [:update]

  def index
    @provider_educations = ProviderEducation.all
  end

  def create
    @provider_education = ProviderEducation.new(practice_information_params)

    if @provider_education.save
      redirect_to mhc_verification_platform_path(page_tab: 'education',id: params[:provider_education][:provider_attest_id]), notice: 'Education detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'education_record',id: params[:provider_education][:provider_attest_id]), alert: 'Failed to save education detail.'
    end
  end

  def update
   @provider_education.assign_attributes(practice_information_params)

    if @provider_education.save
      redirect_to mhc_verification_platform_path(page_tab: 'education',id: params[:provider_education][:provider_attest_id]), notice: 'Education detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'education_record',id: params[:provider_education][:provider_attest_id]), alert: 'Failed to save education detail.'
    end
  end

  private

  def set_provider_education
    @provider_education = ProviderEducation.find(params[:id])
  end

  # Strong parameters for security
  def practice_information_params
    params.require(:provider_education).permit(
      :id, :caqh_provider_education_id, :provider_attest_id, :caqh_provider_attest_id, :institution_name,
      :address, :address2, :suite, :country, :county, :city, :province, :state, :postal_code, :start_date,
      :end_date, :affiliated_university_name, :hospital_department_name, :training_area, :email_address,
      :certificate_issued_by, :program_title, :apa_approved_flag, :program_completed_flag, :program_director,
      :completion_date, :certificate_awarded, :teaching_position, :current_program_director, :incomplete_explanation,
      :phone_number, :fax_number, :disciplinary_action_flag, :disciplinary_action_explanation,
      :program_director_degree, :program_type, :additional_training_description, :education_type_name,
      :hours, :country_country_name, :degree_degree_abbreviation, :specialty_specialty_name,
      :institution_type_institution_type_description
    )
  end
end
