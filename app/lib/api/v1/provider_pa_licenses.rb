module Api
  module V1
    class ProviderPaLicenses < Grape::API

      helpers do
        params :shared_pa_license_params do
          optional :state_id, type: Integer, desc: 'ID of the associated State.'
          optional :pa_license_number, type: String, desc: 'PA license number.'
          optional :no_pa_license, type: String, desc: 'Indicator if no PA license.'
          optional :pa_license_effective_date, type: DateTime, desc: 'PA license effective date.'
          optional :pa_license_expiration_date, type: DateTime, desc: 'PA license expiration date.'
          optional :pa_license_renewal_effective_date, type: DateTime, desc: 'PA license renewal effective date.'
        end
      end

      resource :provider_pa_licenses do

        # GET /api/v1/provider_pa_licenses
        desc "Return a list of provider PA licenses"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :state_id, type: Integer, desc: "Filter by State ID."
        end
        get do
          licenses = ProviderPaLicense.all
          licenses = licenses.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          licenses = licenses.where(state_id: params[:state_id]) if params[:state_id].present?
          present licenses, with: Api::V1::Entities::ProviderPaLicenseEntity
        end

        # POST /api/v1/provider_pa_licenses
        desc "Create a provider PA license record"
        params do
          use :shared_pa_license_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          license_params = declared(params, include_missing: false)
          license = ProviderPaLicense.new(license_params)

          if license.save
            present license, with: Api::V1::Entities::ProviderPaLicenseEntity
          else
            error!({ errors: license.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_pa_licenses/:id
          desc "Return a specific provider PA license record"
          get do
            license = ProviderPaLicense.find(params[:id])
            present license, with: Api::V1::Entities::ProviderPaLicenseEntity
          end

          # PUT /api/v1/provider_pa_licenses/:id
          desc "Update a provider PA license record"
          params do
            use :shared_pa_license_params
          end
          put do
            license = ProviderPaLicense.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if license.update(update_params)
              present license, with: Api::V1::Entities::ProviderPaLicenseEntity
            else
              error!({ errors: license.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_pa_licenses/:id
          desc "Delete a provider PA license record"
          delete do
            license = ProviderPaLicense.find(params[:id])
            if license.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider PA license record"] }, 500)
            end
          end

        end
      end
    end
  end
end
