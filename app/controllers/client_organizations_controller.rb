class ClientOrganizationsController < ApplicationController

  def new
    @client_organization = ClientOrganization.new 
  end

  def create
    client_organization =  ClientOrganization.new(client_organization_params)

    if client_organization.save
      redirect_to manage_clients_path, notice: 'Client organization successfully added.'
    else
      render :new, alert: 'Something went wrong. Please try again.'
    end
  end

  def edit
    @client_organization = ClientOrganization.find(params[:id])
  end

  def update
    # client_organization = ClientOrganization.take
    @client_organization = ClientOrganization.find(params[:id])

    if client_organization.update(client_organization_params)
      redirect_to manage_clients_path, notice: 'Client organization successfully added.'
    else
      render :edit, alert: 'Something went wrong. Please try again.'
    end
  end

  private
  def client_organization_params
    params.require(:client_organization).permit(:organization_name, :organization_type, :organization_npi, :organization_address_1, :organization_address_2, :organization_city, :organization_state_id, :organization_zipcode, :organization_phone_number, :organization_fax_number, :organization_dba_name, :organization_tax_id)
  end
end
