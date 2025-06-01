module Api
  module V1
    class WebscraperCaliforniaStates < Grape::API

      helpers do
        params :shared_california_state_params do
          optional :name, type: String, desc: 'Name of the entity/individual.'
          optional :license_number, type: String, desc: 'License number.'
          optional :license_type, type: String, desc: 'Type of license.'
          optional :license_status, type: String, desc: 'Status of the license.'
          optional :license_expiration, type: String, desc: 'License expiration date.'
          optional :secondary_status, type: String, desc: 'Secondary status.'
          optional :city, type: String, desc: 'City.'
          optional :state, type: String, desc: 'State.'
          optional :county, type: String, desc: 'County.'
          optional :zip, type: String, desc: 'Zip code.'
        end
      end

      resource :webscraper_california_states do

        # GET /api/v1/webscraper_california_states
        desc "Return a list of California scraped records"
        params do
          optional :license_number, type: String, desc: "Filter by license number."
          optional :name, type: String, desc: "Filter by name."
          optional :license_status, type: String, desc: "Filter by license status."
          optional :city, type: String, desc: "Filter by city."
        end
        get do
          records = WebscraperCaliforniaState.all
          records = records.where(license_number: params[:license_number]) if params[:license_number].present?
          records = records.where(name: params[:name]) if params[:name].present?
          records = records.where(license_status: params[:license_status]) if params[:license_status].present?
          records = records.where(city: params[:city]) if params[:city].present?
          present records, with: Api::V1::Entities::WebscraperCaliforniaStateEntity
        end

        # POST /api/v1/webscraper_california_states
        desc "Create a California scraped record"
        params do
          use :shared_california_state_params
        end
        post do
          record_params = declared(params, include_missing: false)
          record = WebscraperCaliforniaState.new(record_params)

          if record.save
            present record, with: Api::V1::Entities::WebscraperCaliforniaStateEntity
          else
            error!({ errors: record.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/webscraper_california_states/:id
          desc "Return a specific California scraped record"
          get do
            record = WebscraperCaliforniaState.find(params[:id])
            present record, with: Api::V1::Entities::WebscraperCaliforniaStateEntity
          end

          # PUT /api/v1/webscraper_california_states/:id
          desc "Update a California scraped record"
          params do
            use :shared_california_state_params
          end
          put do
            record = WebscraperCaliforniaState.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if record.update(update_params)
              present record, with: Api::V1::Entities::WebscraperCaliforniaStateEntity
            else
              error!({ errors: record.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/webscraper_california_states/:id
          desc "Delete a California scraped record"
          delete do
            record = WebscraperCaliforniaState.find(params[:id])
            if record.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete California scraped record"] }, 500)
            end
          end

        end
      end
    end
  end
end
