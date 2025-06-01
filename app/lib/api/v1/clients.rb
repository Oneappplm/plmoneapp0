# app/lib/api/v1/clients.rb

module Api
  module V1
    class Clients < Grape::API

      helpers do
        params :shared_client_params do
          optional :full_name, type: String, desc: 'Client full name.'
          optional :first_name, type: String, desc: 'Client first name.'
          optional :middle_name, type: String, desc: 'Client middle name.'
          optional :last_name, type: String, desc: 'Client last name.'
          optional :provider_name, type: String, desc: 'Associated provider name.'
          optional :birth_date, type: Date, desc: 'Client date of birth.'
          optional :state, type: String, desc: 'Client state.'
          optional :state_abbr, type: String, desc: 'Client state abbreviation.'
          optional :street_address, type: String, desc: 'Client street address.'
          optional :city, type: String, desc: 'Client city.'
          optional :zipcode, type: String, desc: 'Client zipcode.'
          optional :attested_date, type: Date, desc: 'Date attested.'
          optional :npi, type: String, desc: 'Client NPI number.'
          optional :provider_type, type: String, desc: 'Client provider type.'
          optional :specialty, type: String, desc: 'Client specialty.'
          optional :entity, type: String, desc: 'Client entity type.'
          optional :cred_status, type: String, desc: 'Credentialing status.'
          optional :cred_cycle, type: String, desc: 'Credentialing cycle.'
          optional :vrc_status, type: String, desc: 'VRC status.'
          optional :psv_flat, type: String, desc: 'PSV flat info.'
          optional :title, type: String, desc: 'Client title.'
          optional :prefix, type: String, desc: 'Client prefix.'
          optional :suffix, type: String, desc: 'Client suffix.'
          optional :gender, type: String, desc: 'Client gender.'
          optional :prac_type, type: String, desc: 'Practice type.'
          optional :specialty_name, type: String, desc: 'Specialty name.'
          optional :address1, type: String, desc: 'Address line 1.'
          optional :address2, type: String, desc: 'Address line 2.'
          optional :state_or_province, type: String, desc: 'State or province.'
          optional :country, type: String, desc: 'Country.'
          optional :postal_code, type: String, desc: 'Postal code.'
          optional :primary_phone, type: String, desc: 'Primary phone number.'
          optional :primary_email, type: String, desc: 'Primary email address.'
          optional :client_specified_id, type: String, desc: 'Client-specified ID.'
          optional :signature_date, type: String, desc: 'Signature date.'
          optional :file_status, type: String, desc: 'File status.'
          optional :app_receive_date, type: String, desc: 'Application received date.'
          optional :app_receive_complete_date, type: String, desc: 'Application receive complete date.'
          optional :app_complete_date, type: String, desc: 'Application complete date.'
          optional :approval_date, type: String, desc: 'Approval date.'
          optional :cred_or_recred, type: String, desc: 'Credentialing or recredentialing indicator.'
          optional :org_type, type: String, desc: 'Organization type.'
          optional :caqhid, type: String, desc: 'CAQH ID.'
          optional :client_id, type: String, desc: 'Client ID.'
        end
      end

      resource :clients do

        # GET /api/v1/clients
        desc "Return a list of clients"
        params do
          optional :npi, type: String, desc: "Filter by NPI."
          optional :cred_status, type: String, desc: "Filter by credentialing status."
          optional :provider_type, type: String, desc: "Filter by provider type."
        end
        get do
          clients = Client.all
          clients = clients.where(npi: params[:npi]) if params[:npi].present?
          clients = clients.where(cred_status: params[:cred_status]) if params[:cred_status].present?
          clients = clients.where(provider_type: params[:provider_type]) if params[:provider_type].present?
          present clients, with: Api::V1::Entities::ClientEntity
        end

        # POST /api/v1/clients
        desc "Create a client"
        params do
          use :shared_client_params
        end
        post do
          client_params = declared(params, include_missing: false)
          client = Client.new(client_params)

          if client.save
            present client, with: Api::V1::Entities::ClientEntity
          else
            error!({ errors: client.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/clients/:id
          desc "Return a specific client"
          get do
            client = Client.find(params[:id])
            present client, with: Api::V1::Entities::ClientEntity
          end

          # PUT /api/v1/clients/:id
          desc "Update a client"
          params do
            use :shared_client_params
          end
          put do
            client = Client.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if client.update(update_params)
              present client, with: Api::V1::Entities::ClientEntity
            else
              error!({ errors: client.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/clients/:id
          desc "Delete a client"
          delete do
            client = Client.find(params[:id])
            if client.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete client"] }, 500)
            end
          end

        end
      end
    end
  end
end
