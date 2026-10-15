class Mhc::BillingCompaniesController < ApplicationController
  before_action :set_billing_company, only: [:edit, :update, :show, :destroy]
  
  def index
    @billing_companies = BillingCompany.all
  end
  
  def new
    @billing_company = BillingCompany.new
  end
  
  def show
    @billing_company = BillingCompany.find_by(id: params[:billing_company_id])
  
    if @billing_company.nil?
      redirect_to mhc_verification_platform_path(page_tab: 'billing_info'),
                  alert: 'Billing company not found.'
    end
  end
  

  # POST /billing_companies
  def create
    @billing_company = BillingCompany.new(
      billing_company_name: params[:billing_company_name],
      address: params[:address],
      suite: params[:suite],
      additional_address: params[:additional_address],
      city: params[:city],
      county: params[:county],
      state: params[:state],
      zip: params[:zip],
      country: params[:country],
      phone_number: params[:phone_number],
      contact: params[:contact],
      fax_number: params[:fax_number],
      email: params[:email],
      name_affiliated_with_tax_id: params[:name_affiliated_with_tax_id],
      federal_tax_id: params[:federal_tax_id],
      check_payable_to: params[:check_payable_to],
      bills_electronically: params[:bills_electronically],
      comments: params[:comments]
    )

    if @billing_company.save
      # Redirect to the appropriate path on success
      redirect_to mhc_verification_platform_path(id: @billing_company.id, page_tab: 'billing_info'),
            notice: 'Billing info added successfully.'
    else
      # Redirect to the same page with an error message on failure
      redirect_to mhc_verification_platform_path(page_tab: 'billing_info'),
                  alert: 'Failed to add billing info.'
    end
  end
end
