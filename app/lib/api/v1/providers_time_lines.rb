module Api
  module V1
    class ProvidersTimeLines < Grape::API

      helpers do
        params :shared_timeline_params do
          optional :title, type: String, desc: 'Title of the timeline event.'
          optional :due_date, type: DateTime, desc: 'Due date for the timeline event.'
          optional :notes, type: String, desc: 'Notes for the timeline event.'
          optional :status, type: String, desc: 'Status of the timeline event (e.g., pending, completed).'
        end
      end

      resource :providers_time_lines do

        # GET /api/v1/providers_time_lines
        desc "Return a list of provider timeline records"
        params do
          optional :provider_id, type: Integer, desc: "Filter by Provider ID."
          optional :status, type: String, desc: "Filter by status."
        end
        get do
          timelines = ProvidersTimeLine.all
          timelines = timelines.where(provider_id: params[:provider_id]) if params[:provider_id].present?
          timelines = timelines.where(status: params[:status]) if params[:status].present?
          present timelines, with: Api::V1::Entities::ProvidersTimeLineEntity
        end

        # POST /api/v1/providers_time_lines
        desc "Create a provider timeline record"
        params do
          use :shared_timeline_params
          requires :provider_id, type: Integer, desc: 'ID of the associated Provider.'
        end
        post do
          timeline_params = declared(params, include_missing: false)
          timeline = ProvidersTimeLine.new(timeline_params)

          if timeline.save
            present timeline, with: Api::V1::Entities::ProvidersTimeLineEntity
          else
            error!({ errors: timeline.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/providers_time_lines/:id
          desc "Return a specific provider timeline record"
          get do
            timeline = ProvidersTimeLine.find(params[:id])
            present timeline, with: Api::V1::Entities::ProvidersTimeLineEntity
          end

          # PUT /api/v1/providers_time_lines/:id
          desc "Update a provider timeline record"
          params do
            use :shared_timeline_params
          end
          put do
            timeline = ProvidersTimeLine.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if timeline.update(update_params)
              present timeline, with: Api::V1::Entities::ProvidersTimeLineEntity
            else
              error!({ errors: timeline.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/providers_time_lines/:id
          desc "Delete a provider timeline record"
          delete do
            timeline = ProvidersTimeLine.find(params[:id])
            if timeline.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete provider timeline record"] }, 500)
            end
          end

        end
      end
    end
  end
end
