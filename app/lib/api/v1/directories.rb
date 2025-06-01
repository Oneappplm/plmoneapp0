module Api
  module V1
    class Directories < Grape::API

      helpers do
        params :shared_directory_params do
          optional :name, type: String, desc: 'Name of the directory.'
        end
      end

      resource :directories do

        # GET /api/v1/directories
        desc "Return a list of directories"
        get do
          directories = Directory.all
          present directories, with: Api::V1::Entities::DirectoryEntity
        end

        # POST /api/v1/directories
        desc "Create a directory"
        params do
          use :shared_directory_params
          requires :name
        end
        post do
          directory_params = declared(params, include_missing: false)
          directory = Directory.new(directory_params)

          if directory.save
            present directory, with: Api::V1::Entities::DirectoryEntity
          else
            error!({ errors: directory.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/directories/:id
          desc "Return a specific directory"
          get do
            directory = Directory.find(params[:id])
            present directory, with: Api::V1::Entities::DirectoryEntity
          end

          # PUT /api/v1/directories/:id
          desc "Update a directory"
          params do
            use :shared_directory_params
          end
          put do
            directory = Directory.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if directory.update(update_params)
              present directory, with: Api::V1::Entities::DirectoryEntity
            else
              error!({ errors: directory.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/directories/:id
          desc "Delete a directory"
          delete do
            directory = Directory.find(params[:id])
            if directory.destroy
              status 204
              {}
            else
              error!({ errors: ["Failed to delete directory"] }, 500)
            end
          end

        end
      end
    end
  end
end
