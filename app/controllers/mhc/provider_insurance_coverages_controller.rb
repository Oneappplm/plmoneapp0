class Mhc::ProviderInsuranceCoveragesController < ApplicationController

  def index
    @provider_insurance_coverages = ProviderInsuranceCoverage.all
  end

  def new
    @provider_insurance_coverage = ProviderInsuranceCoverage.new
    @states = State.all
    @insurance_carriers = ProviderInsuranceCoverage.pluck(:insurance_carrier_name).uniq
  end

  def create
    @provider_insurance_coverage = ProviderInsuranceCoverage.new(provider_insurance_coverages_params)

    if @provider_insurance_coverage.save
      redirect_to mhc_verification_platform_path(page_tab: 'liability',id: params[:provider_insurance_coverage][:provider_attest_id]), notice: 'liability detail saved successfully.'
    end
  end

  def edit
    @provider_insurance_coverage = ProviderInsuranceCoverage.find(params[:id])
  end

  def update
    @provider_insurance_coverage = ProviderInsuranceCoverage.find(params[:id])
    if @provider_insurance_coverage.update(provider_insurance_coverages_params)
      redirect_to mhc_verification_platform_path(page_tab: 'liability',id: params[:provider_insurance_coverage][:provider_attest_id]), notice: 'liability detail updated successfully.'
    end
  end

  def destroy
    @provider_insurance_coverage = ProviderInsuranceCoverage.find(params[:id])
    if @provider_insurance_coverage.destroy
      redirect_to mhc_verification_platform_path(page_tab: 'liability', id: params[:provider_attest_id]), alert: 'liability detail deleted successfully.'
    end
  end

  private

  # Strong parameters for security
  def provider_insurance_coverages_params
    params.require(:provider_insurance_coverage).permit(
      :id, 
      :caqh_provider_insurance_id,
      :provider_attest_id,
      :caqh_provider_attest_id,
      :insurance_carrier_name,
      :original_start_date,
      :start_date,
      :end_date,
      :self_insured_flag,
      :address,
      :address2,
      :city,
      :state,
      :province,
      :postal_code,
      :phone_number,
      :policy_number,
      :individual_coverage_flag,
      :coverage_amount_occurrence,
      :coverage_amount_aggregate,
      :agent_last_name,
      :agent_first_name,
      :policy_holder,
      :no_malpractice_claims_flag,
      :retroactive_date,
      :tail_nose_coverage_flag,
      :tail_nose_coverage_explanation,
      :time_with_carrier,
      :coverage_limit_exceeded_flag,
      :unlimited_coverage_flag,
      :fax_number,
      :website,
      :renewal_date,
      :agent_address,
      :agent_address2,
      :agent_city,
      :agent_state,
      :agent_postal_code,
      :agent_province,
      :surcharge_explanation,
      :excess_coverage_amount,
      :phone_extension,
      :underwriter_name,
      :affiliated_organization_name,
      :agent_country_country_name,
      :country_country_name,
      :insurance_type_insurance_type_description,
      :insurance_coverage_type_insurance_coverage_type_description,
      :type_of_policy,
      :additional_address,
      :email_address,
      :effective_date,
      :claim_amount,
      :umbrella_coverage_amount,
      :tail_coverage,
      :current_carrier_excluded,
      :current_carrier_excluded_explanation,
      :show_on_tickler,
      :comment,
      :liability_not_applicable,
      :liability_explanation
    )
  end
end
