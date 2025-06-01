module Api
  module V1
    class ProviderCdsLicenses < Grape::API

      helpers do
        params :shared_cds_license_params do
          optional :state_id, type: Integer, desc: 'ID of the associated State.'
          optional :cds_license_number, type: String, desc: 'CDS license number.'
          optional :no_cds_license, type: String, desc: 'Indicator if no CDS license.'
          optional :cds_license_issue_date, type: DateTime, desc: 'CDS license issue date.'
          optional :cds_license_expiration_date, type: DateTime, desc: 'CDS license expiration date.'
          optional :cds_renewal_effective_date, type: DateTime, desc: 'CDS renewal effective date.'
        end
      end

      resource :provider_cds_licenses do

        # GET /api/v1/provider_cds_licenses
        desc "Return a list of provider CDS licenses"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :state_id, type: Integer, desc: "Filter by State ID."
        end
        get do
          licenses = ProviderCdsLicense.all
          licenses = licenses.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          licenses = licenses.where(state_id: params[:state_id]) if params[:state_id].present?
          present licenses, with: Api::V1::Entities::ProviderCdsLicenseEntity
        end

        # POST /api/v1/provider_cds_licenses
        desc "Create a provider CDS license record"
        params do
          use :shared_cds_license_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          license_params = declared(params, include_missing: false)
          license = ProviderCdsLicense.new(license_params)

          if license.save
            present license, with: Api::V1::Entities::ProviderCdsLicenseEntity
          else
            error!({ errors: license.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_cds_licenses/:id
          desc "Return a specific provider CDS license record"
          get do
            license = ProviderCdsLicense.find(params[:id])
            present license, with: Api::V1::Entities::ProviderCdsLicenseEntity
          end

          # PUT /api/v1/provider_cds_licenses/:id
          desc "Update a provider CDS license record"
          params do
            use :shared_cds_license_params
          end
          put do
            license = ProviderCdsLicense.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if license.update(update_params)
              present license, with: Api::V1::Entities::ProviderCdsLicenseEntity
            else
              error!({ errors: license.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_cds_licenses/:id
          desc "Delete a provider CDS license record"
          delete do
            license = ProviderCdsLicense.find(params[:id])
            if license.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider CDS license record"] }, 500)
            end
          end

        end
      end
    end
  end
end
