module Api
  module V1
    class ProviderCnpLicenses < Grape::API

      helpers do
        params :shared_cnp_license_params do
          optional :state_id, type: Integer, desc: 'ID of the associated State.'
          optional :cnp_license_number, type: String, desc: 'CNP license number.'
          optional :no_cnp_license, type: String, desc: 'Indicator if no CNP license.'
          optional :effective_date, type: DateTime, desc: 'CNP license effective date.'
          optional :expiration_date, type: DateTime, desc: 'CNP license expiration date.'
          optional :cnp_license_renewal_effective_date, type: DateTime, desc: 'CNP renewal effective date.'
        end
      end

      resource :provider_cnp_licenses do

        # GET /api/v1/provider_cnp_licenses
        desc "Return a list of provider CNP licenses"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :state_id, type: Integer, desc: "Filter by State ID."
        end
        get do
          licenses = ProviderCnpLicense.all
          licenses = licenses.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          licenses = licenses.where(state_id: params[:state_id]) if params[:state_id].present?
          present licenses, with: Api::V1::Entities::ProviderCnpLicenseEntity
        end

        # POST /api/v1/provider_cnp_licenses
        desc "Create a provider CNP license record"
        params do
          use :shared_cnp_license_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          license_params = declared(params, include_missing: false)
          license = ProviderCnpLicense.new(license_params)

          if license.save
            present license, with: Api::V1::Entities::ProviderCnpLicenseEntity
          else
            error!({ errors: license.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_cnp_licenses/:id
          desc "Return a specific provider CNP license record"
          get do
            license = ProviderCnpLicense.find(params[:id])
            present license, with: Api::V1::Entities::ProviderCnpLicenseEntity
          end

          # PUT /api/v1/provider_cnp_licenses/:id
          desc "Update a provider CNP license record"
          params do
            use :shared_cnp_license_params
          end
          put do
            license = ProviderCnpLicense.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if license.update(update_params)
              present license, with: Api::V1::Entities::ProviderCnpLicenseEntity
            else
              error!({ errors: license.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_cnp_licenses/:id
          desc "Delete a provider CNP license record"
          delete do
            license = ProviderCnpLicense.find(params[:id])
            if license.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider CNP license record"] }, 500)
            end
          end

        end
      end
    end
  end
end
