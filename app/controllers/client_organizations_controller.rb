class ClientOrganizationsController < ApplicationController
  def create
    #render json: params and return
    @client_organization = ClientOrganization.new(client_organization_params)
    if @client_organization.save
      redirect_to request.referrer, notice: 'Client organization successfully added.'
    end
  end
  
  private

  def client_organization_params
    params.require(:client_organization).permit(:organization_name, :organization_type, :organization_npi, :organization_address_1, :organization_address_2, :organization_city, :organization_state_id, :organization_zipcode, :organization_phone_number, :organization_fax_number, :organization_dba_number, :organization_tax_id)
  end
end
