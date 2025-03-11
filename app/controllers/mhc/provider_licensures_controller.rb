class Mhc::ProviderLicensuresController < ApplicationController
	before_action :set_provider_licensure, only: [:update]

	def create
		@provider_licensure = ProviderLicensure.new(provider_licensure_params)
		if @provider_licensure.save
			redirect_to mhc_verification_platform_path(page_tab: 'licensure',id: params[:provider_licensure][:provider_attest_id]), notice: 'Provider licensure detail saved successfully.'
		else
			redirect_to mhc_verification_platform_path(page_tab: 'licensure',id: params[:provider_licensure][:provider_attest_id]), alert: 'Failed to save provider licensure detail.'
		end
	end

	def update
		if @provider_licensure.update(provider_licensure_params)
			redirect_to mhc_verification_platform_path(page_tab: 'licensure',id: params[:provider_licensure][:provider_attest_id]), notice: 'Provider licensure detail updated successfully.'
		else
			redirect_to mhc_verification_platform_path(page_tab: 'licensure',id: params[:provider_licensure][:provider_attest_id]), alert: 'Failed to save provider licensure detail.'
		end
	end

	def destroy
		@provider_licensure = ProviderLicensure.find(params[:id])
    if @provider_licensure.destroy
      redirect_to mhc_verification_platform_path(page_tab: 'licensure', id: @provider_licensure.provider_attest_id), 
                  notice: 'Licensure detail deleted successfully.'
    else
      redirect_to mhc_verification_platform_path(page_tab: 'licensure', id: @provider_licensure.provider_attest_id), 
                  alert: 'Failed to delete licensure detail.'
    end
  end

	private

	def set_provider_licensure
		@provider_licensure = ProviderLicensure.find(params[:provider_licensure][:id])
	end

	def provider_licensure_params
		params.require(:provider_licensure).permit(
			:provider_attest_id,
			:caqh_provider_attest_id,
			:license_number,
			:license_issue_date,
			:license_expiration_date,
			:state_id,
			:license_type,
			:currently_practice_under_this,
			:is_primary_license,
			:level_require_supervision,
			:failed_state_license_exam,
			:license_person_type,
			:license_comment,
			:show_on_tickler,
			provider_supervisings_attributes: [
				:id, 
				:name_of_supervising, 
				:license_state, 
				:license_type, 
				:license_number, 
				:facility, 
				:address, 
				:mail_stop, 
				:address2, 
				:city, 
				:state, 
				:country, 
				:zipcode, 
				:phone_number, 
				:fax_number, 
				:email_address,
				:_destroy
			]
			)
	end
end

