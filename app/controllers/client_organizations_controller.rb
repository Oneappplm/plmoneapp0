class ClientOrganizationsController < ApplicationController
  def create
    client_organization =  ClientOrganization.new(client_organization_params)

    if client_organization.save
      redirect_to request.referrer, notice: 'Client organization successfully added.'
    else
      redirect_to request.referrer, alert: 'Something went wrong. Please try again.'
    end
  end

  def update
    client_organization = ClientOrganization.take

    if client_organization.update(client_organization_params)
      redirect_to request.referrer, notice: 'Client organization successfully added.'
    else
      redirect_to request.referrer, alert: 'Something went wrong. Please try again.'
    end
  end

  def download_pdfs
    client = Client.find(params[:id])
    zip_file = ZipGeneratorService.create_zip(client)

    if zip_file
      send_file zip_file.path, type: 'application/zip', disposition: 'attachment', filename: "client_#{client.id}_pdfs.zip"
    else
      redirect_to clients_path, alert: 'Failed to create ZIP file.'
    end
  ensure
    zip_file.unlink if zip_file # Deletes the temp file
  end


  private
  def client_organization_params
    params.require(:client_organization).permit(:organization_name, :organization_type, :organization_npi, :organization_address_1, :organization_address_2, :organization_city, :organization_state_id, :organization_zipcode, :organization_phone_number, :organization_fax_number, :organization_dba_name, :organization_tax_id)
  end
end
