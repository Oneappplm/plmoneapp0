module Api
  module V1
    class ProviderRnLicenses < Grape::API

      helpers do
        params :shared_rn_license_params do
          optional :state_id, type: Integer, desc: 'ID of the associated State.'
          optional :rn_license_number, type: String, desc: 'RN license number.'
          optional :no_rn_license, type: String, desc: 'Indicator if no RN license.'
          optional :rn_license_effective_date, type: Date, desc: 'RN license effective date.'
          optional :rn_license_expiration_date, type: Date, desc: 'RN license expiration date.'
          optional :rn_license_renewal_effective_date, type: String, desc: 'RN license renewal effective date.'
        end
      end

      resource :provider_rn_licenses do

        # GET /api/v1/provider_rn_licenses
        desc "Return a list of provider RN licenses"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :state_id, type: Integer, desc: "Filter by State ID."
        end
        get do
          licenses = ProviderRnLicense.all
          licenses = licenses.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          licenses = licenses.where(state_id: params[:state_id]) if params[:state_id].present?
          present licenses, with: Api::V1::Entities::ProviderRnLicenseEntity
        end

        # POST /api/v1/provider_rn_licenses
        desc "Create a provider RN license record"
        params do
          use :shared_rn_license_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          license_params = declared(params, include_missing: false)
          license = ProviderRnLicense.new(license_params)

          if license.save
            present license, with: Api::V1::Entities::ProviderRnLicenseEntity
          else
            error!({ errors: license.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_rn_licenses/:id
          desc "Return a specific provider RN license record"
          get do
            license = ProviderRnLicense.find(params[:id])
            present license, with: Api::V1::Entities::ProviderRnLicenseEntity
          end

          # PUT /api/v1/provider_rn_licenses/:id
          desc "Update a provider RN license record"
          params do
            use :shared_rn_license_params
          end
          put do
            license = ProviderRnLicense.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if license.update(update_params)
              present license, with: Api::V1::Entities::ProviderRnLicenseEntity
            else
              error!({ errors: license.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_rn_licenses/:id
          desc "Delete a provider RN license record"
          delete do
            license = ProviderRnLicense.find(params[:id])
            if license.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider RN license record"] }, 500)
            end
          end

        end
      end
    end
  end
end
