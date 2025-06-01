module Api
  module V1
    class BoardNames < Grape::API

      helpers do
        params :shared_board_name_params do
          requires :name, type: String, desc: 'Name of the board'
        end
      end

      resource :board_names do

        # GET /api/v1/board_names
        desc 'Return all board names'
        get do
          board_names = BoardName.all
          present board_names, with: Api::V1::Entities::BoardNameEntity
        end

        # POST /api/v1/board_names
        desc 'Create a board name'
        params do
          use :shared_board_name_params
        end
        post do
          board_name = BoardName.new(declared(params, include_missing: false))

          if board_name.save
            present board_name, with: Api::V1::Entities::BoardNameEntity
          else
            error!({ errors: board_name.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/board_names/:id
          desc 'Return a specific board name'
          get do
            board_name = BoardName.find(params[:id])
            present board_name, with: Api::V1::Entities::BoardNameEntity
          end

          # PUT /api/v1/board_names/:id
          desc 'Update a board name'
          params do
            use :shared_board_name_params
          end
          put do
            board_name = BoardName.find(params[:id])
            update_params = declared(params, include_missing: false)

            if board_name.update(update_params)
              present board_name, with: Api::V1::Entities::BoardNameEntity
            else
              error!({ errors: board_name.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/board_names/:id
          desc 'Delete a board name'
          delete do
            board_name = BoardName.find(params[:id])
            if board_name.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete board name'] }, 500)
            end
          end

        end
      end
    end
  end
end
