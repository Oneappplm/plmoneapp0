module Api
  module V1
    class ProviderDeaLicenses < Grape::API

      helpers do
        params :shared_dea_license_params do
          optional :state_id, type: Integer, desc: 'ID of the associated State.'
          optional :dea_license_number, type: String, desc: 'DEA license number.'
          optional :dea_license_effective_date, type: DateTime, desc: 'DEA license effective date.'
          optional :dea_license_expiration_date, type: DateTime, desc: 'DEA license expiration date.'
          optional :dea_license_renewal_effective_date, type: String, desc: 'DEA license renewal effective date.'
          optional :no_dea_license, type: String, desc: 'Indicator if no DEA license.'
        end
      end

      resource :provider_dea_licenses do

        # GET /api/v1/provider_dea_licenses
        desc "Return a list of provider DEA licenses"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :state_id, type: Integer, desc: "Filter by State ID."
        end
        get do
          licenses = ProviderDeaLicense.all
          licenses = licenses.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          licenses = licenses.where(state_id: params[:state_id]) if params[:state_id].present?
          present licenses, with: Api::V1::Entities::ProviderDeaLicenseEntity
        end

        # POST /api/v1/provider_dea_licenses
        desc "Create a provider DEA license record"
        params do
          use :shared_dea_license_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          license_params = declared(params, include_missing: false)
          license = ProviderDeaLicense.new(license_params)

          if license.save
            present license, with: Api::V1::Entities::ProviderDeaLicenseEntity
          else
            error!({ errors: license.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_dea_licenses/:id
          desc "Return a specific provider DEA license record"
          get do
            license = ProviderDeaLicense.find(params[:id])
            present license, with: Api::V1::Entities::ProviderDeaLicenseEntity
          end

          # PUT /api/v1/provider_dea_licenses/:id
          desc "Update a provider DEA license record"
          params do
            use :shared_dea_license_params
          end
          put do
            license = ProviderDeaLicense.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if license.update(update_params)
              present license, with: Api::V1::Entities::ProviderDeaLicenseEntity
            else
              error!({ errors: license.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_dea_licenses/:id
          desc "Delete a provider DEA license record"
          delete do
            license = ProviderDeaLicense.find(params[:id])
            if license.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider DEA license record"] }, 500)
            end
          end

        end
      end
    end
  end
end
