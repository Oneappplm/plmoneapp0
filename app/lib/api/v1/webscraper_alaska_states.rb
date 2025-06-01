module Api
  module V1
    class WebscraperAlaskaStates < Grape::API

      helpers do
        params :shared_alaska_state_params do
          optional :program, type: String, desc: 'Program name.'
          optional :license_number, type: String, desc: 'License number.'
          optional :dba, type: String, desc: 'DBA (Doing Business As) name.'
          optional :owners, type: String, desc: 'Owners of the entity.'
          optional :status, type: String, desc: 'Status of the license/entity.'
          optional :license_expiration, type: String, desc: 'License expiration date.'
        end
      end

      resource :webscraper_alaska_states do

        # GET /api/v1/webscraper_alaska_states
        desc "Return a list of Alaska scraped records"
        params do
          optional :program, type: String, desc: "Filter by program name."
          optional :license_number, type: String, desc: "Filter by license number."
          optional :status, type: String, desc: "Filter by status."
        end
        get do
          records = WebscraperAlaskaState.all
          records = records.where(program: params[:program]) if params[:program].present?
          records = records.where(license_number: params[:license_number]) if params[:license_number].present?
          records = records.where(status: params[:status]) if params[:status].present?
          present records, with: Api::V1::Entities::WebscraperAlaskaStateEntity
        end

        # POST /api/v1/webscraper_alaska_states
        desc "Create an Alaska scraped record"
        params do
          use :shared_alaska_state_params
        end
        post do
          record_params = declared(params, include_missing: false)
          record = WebscraperAlaskaState.new(record_params)

          if record.save
            present record, with: Api::V1::Entities::WebscraperAlaskaStateEntity
          else
            error!({ errors: record.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/webscraper_alaska_states/:id
          desc "Return a specific Alaska scraped record"
          get do
            record = WebscraperAlaskaState.find(params[:id])
            present record, with: Api::V1::Entities::WebscraperAlaskaStateEntity
          end

          # PUT /api/v1/webscraper_alaska_states/:id
          desc "Update an Alaska scraped record"
          params do
            use :shared_alaska_state_params
          end
          put do
            record = WebscraperAlaskaState.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if record.update(update_params)
              present record, with: Api::V1::Entities::WebscraperAlaskaStateEntity
            else
              error!({ errors: record.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/webscraper_alaska_states/:id
          desc "Delete an Alaska scraped record"
          delete do
            record = WebscraperAlaskaState.find(params[:id])
            if record.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete Alaska scraped record"] }, 500)
            end
          end

        end
      end
    end
  end
end
