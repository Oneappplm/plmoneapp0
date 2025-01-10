class Mhc::ClientOrganizationsController < ApplicationController

  def new
    @client_organization = ClientOrganization.new 
  end

  def create
    client_organization =  ClientOrganization.new(client_organization_params)

    if client_organization.save
      redirect_to mhc_manage_clients_path, notice: 'Client organization successfully added.'
    else
      render :new, alert: 'Something went wrong. Please try again.'
    end
  end

  def edit_client_organization
    @client_organizations = ClientOrganization.select(:id, :organization_name).distinct
    @client_organization = nil
  end

  def load_client_organization
    organization_id = params[:client_organization_id]
    @client_organizations = ClientOrganization.select(:id, :organization_name).distinct
    @client_organization = ClientOrganization.find_by(id: organization_id)

    if @client_organization
      render :edit_client_organization
    else
      redirect_to edit_client_organization_mhc_client_organizations_path,
                  alert: 'Organization not found. Please select a valid organization.'
    end
  end

  def update_client_organization
    @client_organization = ClientOrganization.find(params[:id])

    if @client_organization.update(client_organization_params)
      redirect_to mhc_manage_clients_path, notice: 'Client Organization updated successfully.'
    else
      @client_organizations = ClientOrganization.select(:id, :organization_name).distinct
      render :edit_client_organization, status: :unprocessable_entity
    end
  end

  private
  def client_organization_params
    params.require(:client_organization).permit(
      :organization_name,
      :organization_type,
      :organization_npi,
      :organization_address_1,
      :organization_address_2,
      :organization_city,
      :organization_state_id,
      :organization_zipcode,
      :organization_phone_number,
      :organization_fax_number,
      :organization_dba_name,
      :organization_tax_id,
      :primary_service,
      :tin_number,
      :tin_name,
      :organization_facility_type,
      :credential, 
      :recredential,
      :contact_method,
      :contact_first_name,
      :contact_middle_name,
      :contact_last_name,
      :contact_suffix,
      :email_address,
      :mail_stop,
      :organization_country,
      :client_due_date,
      :client_batch_date,
      :client_batch_name,
      :client_batch_id
    )
  end
end
