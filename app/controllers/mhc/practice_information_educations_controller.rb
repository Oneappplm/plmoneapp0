class Mhc::PracticeInformationEducationsController < ApplicationController
  before_action :set_practice_information_education, only: [:update, :destroy]

  def index
    @practice_information_educations = PracticeInformationEducation.all
  end

  def create
    @practice_information_education = PracticeInformationEducation.new(practice_information_education_params)

    if @practice_information_education.save
      redirect_to mhc_verification_platform_path(page_tab: 'education',id: params[:practice_information_education][:provider_attest_id]), notice: 'Education detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'education_record',id: params[:practice_information_education][:provider_attest_id]), alert: 'Failed to save education detail.'
    end
  end

  def update
   @practice_information_education.assign_attributes(practice_information_education_params)

    if @practice_information_education.save
      redirect_to mhc_verification_platform_path(page_tab: 'education',id: params[:practice_information_education][:provider_attest_id]), notice: 'Education detail saved successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'education_record',id: params[:practice_information_education][:provider_attest_id]), alert: 'Failed to save education detail.'
    end
  end

  def destroy
    provider_attest_id = params[:provider_attest_id] || @practice_information_education.provider_attest_id
  
    if @practice_information_education.destroy
      redirect_to mhc_verification_platform_path(page_tab: 'education', id: provider_attest_id), notice: 'Education detail deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'education', id: provider_attest_id), alert: 'Failed to delete education detail.'
    end
  end  

  private

  def set_practice_information_education
    @practice_information_education = PracticeInformationEducation.find(params[:id])
  end

  # Strong parameters for security
  def practice_information_education_params
    params.require(:practice_information_education).permit(
      :id, :provider_attest_id, :institution_name, :caqh_provider_attest_id,
      :address, :address2, :country, :county, :city, :province, :state, :postal_code, :start_date,
      :end_date, :email_address, :program_title, :program_completed_flag, :incomplete_explanation,
      :phone_number, :fax_number, :degree_degree_abbreviation, :suite_dept_mail_stop, :if_other_list, :comments, :show_on_tickler
    )
  end
end
