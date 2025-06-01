module Api
  module V1
    class ProviderLicenses < Grape::API

      helpers do
        params :shared_license_params do
          optional :state_id, type: Integer, desc: 'ID of the associated State.'
          optional :license_number, type: String, desc: 'License number.'
          optional :license_effective_date, type: Date, desc: 'License effective date.'
          optional :license_expiration_date, type: Date, desc: 'License expiration date.'
          optional :license_state_renewal_date, type: String, desc: 'License state renewal date.'
          optional :no_state_license, type: String, desc: 'Indicator if no state license.'
          optional :license_type, type: String, desc: 'Type of license.'
        end
      end

      resource :provider_licenses do

        # GET /api/v1/provider_licenses
        desc "Return a list of provider licenses"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :state_id, type: Integer, desc: "Filter by State ID."
          optional :license_type, type: String, desc: "Filter by license type."
        end
        get do
          licenses = ProviderLicense.all
          licenses = licenses.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          licenses = licenses.where(state_id: params[:state_id]) if params[:state_id].present?
          licenses = licenses.where(license_type: params[:license_type]) if params[:license_type].present?
          present licenses, with: Api::V1::Entities::ProviderLicenseEntity
        end

        # POST /api/v1/provider_licenses
        desc "Create a provider license record"
        params do
          use :shared_license_params
        end
        post do
          license_params = declared(params, include_missing: false)
          license = ProviderLicense.new(license_params)

          if license.save
            present license, with: Api::V1::Entities::ProviderLicenseEntity
          else
            error!({ errors: license.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_licenses/:id
          desc "Return a specific provider license record"
          get do
            license = ProviderLicense.find(params[:id])
            present license, with: Api::V1::Entities::ProviderLicenseEntity
          end

          # PUT /api/v1/provider_licenses/:id
          desc "Update a provider license record"
          params do
            use :shared_license_params
            optional :provider_id, type: Integer, desc: 'ID of the associated Provider.'
          end
          put do
            license = ProviderLicense.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if license.update(update_params)
              present license, with: Api::V1::Entities::ProviderLicenseEntity
            else
              error!({ errors: license.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_licenses/:id
          desc "Delete a provider license record"
          delete do
            license = ProviderLicense.find(params[:id])
            if license.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider license record"] }, 500)
            end
          end

        end
      end
    end
  end
end
