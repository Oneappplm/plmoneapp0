module Api
  module V1
    class ProviderBoardCertifications < Grape::API

      helpers do
        params :shared_board_cert_params do
          optional :bc_board_certification, type: String, desc: 'Board certification status/info.'
          optional :bc_board_name, type: String, desc: 'Name of the certifying board.'
          optional :bc_certification_number, type: String, desc: 'Certification number.'
          optional :bc_specialty_type, type: String, desc: 'Type of specialty.'
          optional :bc_effective_date, type: DateTime, desc: 'Certification effective date.'
          optional :bc_expiration_date, type: DateTime, desc: 'Certification expiration date.'
          optional :bc_recertification_date, type: DateTime, desc: 'Recertification date.'
        end
      end

      resource :provider_board_certifications do

        # GET /api/v1/provider_board_certifications
        desc "Return a list of provider board certifications"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :bc_board_name, type: String, desc: "Filter by board name."
          optional :bc_specialty_type, type: String, desc: "Filter by specialty type."
        end
        get do
          certs = ProviderBoardCertification.all
          certs = certs.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          certs = certs.where(bc_board_name: params[:bc_board_name]) if params[:bc_board_name].present?
          certs = certs.where(bc_specialty_type: params[:bc_specialty_type]) if params[:bc_specialty_type].present?
          present certs, with: Api::V1::Entities::ProviderBoardCertificationEntity
        end

        # POST /api/v1/provider_board_certifications
        desc "Create a provider board certification record"
        params do
          use :shared_board_cert_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          cert_params = declared(params, include_missing: false)
          cert = ProviderBoardCertification.new(cert_params)

          if cert.save
            present cert, with: Api::V1::Entities::ProviderBoardCertificationEntity
          else
            error!({ errors: cert.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/provider_board_certifications/:id
          desc "Return a specific provider board certification record"
          get do
            cert = ProviderBoardCertification.find(params[:id])
            present cert, with: Api::V1::Entities::ProviderBoardCertificationEntity
          end

          # PUT /api/v1/provider_board_certifications/:id
          desc "Update a provider board certification record"
          params do
            use :shared_board_cert_params
            optional :provider_id, type: Integer, desc: 'ID of the associated Provider.' # If re-assigning is allowed
          end
          put do
            cert = ProviderBoardCertification.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if cert.update(update_params)
              present cert, with: Api::V1::Entities::ProviderBoardCertificationEntity
            else
              error!({ errors: cert.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/provider_board_certifications/:id
          desc "Delete a provider board certification record"
          delete do
            cert = ProviderBoardCertification.find(params[:id])
            if cert.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider board certification record"] }, 500)
            end
          end

        end
      end
    end
  end
end
