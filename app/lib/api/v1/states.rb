module Api
  module V1
    class States < Grape::API

      helpers do
        params :shared_state_params do
          requires :name, type: String, desc: 'Name of the state'
          requires :abbreviation, type: String, desc: 'Two-letter abbreviation of the state'
        end
      end

      resource :states do

        # GET /api/v1/states
        desc 'Return all states'
        get do
          states = State.all
          present states, with: Api::V1::Entities::StateEntity
        end

        # POST /api/v1/states
        desc 'Create a state'
        params do
          use :shared_state_params
        end
        post do
          state = State.new(declared(params, include_missing: false))

          if state.save
            present state, with: Api::V1::Entities::StateEntity
          else
            error!({ errors: state.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/states/:id
          desc 'Return a specific state'
          get do
            state = State.find(params[:id])
            present state, with: Api::V1::Entities::StateEntity
          end

          # PUT /api/v1/states/:id
          desc 'Update a state'
          params do
            use :shared_state_params
          end
          put do
            state = State.find(params[:id])
            update_params = declared(params, include_missing: false)

            if state.update(update_params)
              present state, with: Api::V1::Entities::StateEntity
            else
              error!({ errors: state.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/states/:id
          desc 'Delete a state'
          delete do
            state = State.find(params[:id])
            if state.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete state'] }, 500)
            end
          end

        end
      end
    end
  end
end
