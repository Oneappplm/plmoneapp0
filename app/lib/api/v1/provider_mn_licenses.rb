module Api
  module V1
    class ProviderMnLicenses < Grape::API

      helpers do
        params :shared_mn_license_params do
          optional :mn_license_number, type: String, desc: 'MN license number.'
          optional :mn_license_expiration_date, type: DateTime, desc: 'MN license expiration date.'
        end
      end

      resource :provider_mn_licenses do

        # GET /api/v1/provider_mn_licenses
        desc "Return a list of provider MN licenses"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
        end
        get do
          licenses = ProviderMnLicense.all
          licenses = licenses.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          present licenses, with: Api::V1::Entities::ProviderMnLicenseEntity
        end

        # POST /api/v1/provider_mn_licenses
        desc "Create a provider MN license record"
        params do
          use :shared_mn_license_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          license_params = declared(params, include_missing: false)
          license = ProviderMnLicense.new(license_params)

          if license.save
            present license, with: Api::V1::Entities::ProviderMnLicenseEntity
          else
            error!({ errors: license.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_mn_licenses/:id
          desc "Return a specific provider MN license record"
          get do
            license = ProviderMnLicense.find(params[:id])
            present license, with: Api::V1::Entities::ProviderMnLicenseEntity
          end

          # PUT /api/v1/provider_mn_licenses/:id
          desc "Update a provider MN license record"
          params do
            use :shared_mn_license_params
          end
          put do
            license = ProviderMnLicense.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if license.update(update_params)
              present license, with: Api::V1::Entities::ProviderMnLicenseEntity
            else
              error!({ errors: license.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_mn_licenses/:id
          desc "Delete a provider MN license record"
          delete do
            license = ProviderMnLicense.find(params[:id])
            if license.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider MN license record"] }, 500)
            end
          end

        end
      end
    end
  end
end
