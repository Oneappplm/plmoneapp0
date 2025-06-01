module Api
  module V1
    class ClientOrganizations < Grape::API

      helpers do
        params :shared_client_org_params do
          optional :organization_name, type: String, desc: 'Name of the organization.'
          optional :organization_type, type: String, desc: 'Type of the organization.'
          optional :organization_npi, type: String, desc: 'Organization NPI number.'
          optional :organization_address_1, type: String, desc: 'Organization address line 1.'
          optional :organization_address_2, type: String, desc: 'Organization address line 2.'
          optional :organization_city, type: String, desc: 'Organization city.'
          optional :organization_state_id, type: Integer, desc: 'ID of the organization state.'
          optional :organization_zipcode, type: String, desc: 'Organization zipcode.'
          optional :organization_phone_number, type: String, desc: 'Organization phone number.'
          optional :organization_fax_number, type: String, desc: 'Organization fax number.'
          optional :organization_dba_name, type: String, desc: 'Organization DBA name.'
          optional :organization_tax_id, type: String, desc: 'Organization Tax ID (Sensitive).'
        end
      end

      resource :client_organizations do

        # GET /api/v1/client_organizations
        desc "Return a list of client organizations"
        params do
          optional :organization_name, type: String, desc: "Filter by organization name."
          optional :organization_type, type: String, desc: "Filter by organization type."
          optional :organization_state_id, type: Integer, desc: "Filter by state ID."
        end
        get do
          orgs = ClientOrganization.all
          orgs = orgs.where(organization_name: params[:organization_name]) if params[:organization_name].present?
          orgs = orgs.where(organization_type: params[:organization_type]) if params[:organization_type].present?
          orgs = orgs.where(organization_state_id: params[:organization_state_id]) if params[:organization_state_id].present?
          present orgs, with: Api::V1::Entities::ClientOrganizationEntity
        end

        # POST /api/v1/client_organizations
        desc "Create a client organization"
        params do
          use :shared_client_org_params
          requires :organization_name
        end
        post do
          org_params = declared(params, include_missing: false)
          org = ClientOrganization.new(org_params)

          if org.save
            present org, with: Api::V1::Entities::ClientOrganizationEntity
          else
            error!({ errors: org.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/client_organizations/:id
          desc "Return a specific client organization"
          get do
            org = ClientOrganization.find(params[:id])
            present org, with: Api::V1::Entities::ClientOrganizationEntity
          end

          # PUT /api/v1/client_organizations/:id
          desc "Update a client organization"
          params do
            use :shared_client_org_params
          end
          put do
            org = ClientOrganization.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if org.update(update_params)
              present org, with: Api::V1::Entities::ClientOrganizationEntity
            else
              error!({ errors: org.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/client_organizations/:id
          desc "Delete a client organization"
          delete do
            org = ClientOrganization.find(params[:id])
            if org.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete client organization"] }, 500)
            end
          end

        end
      end
    end
  end
end
