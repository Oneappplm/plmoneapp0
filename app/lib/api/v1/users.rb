module Api
  module V1
    class Users < Grape::API

      helpers do
        params :shared_user_params do
          optional :email, type: String, desc: 'User email address.', regexp: /.+@.+/
          optional :first_name, type: String, desc: 'User first name.'
          optional :last_name, type: String, desc: 'User last name.'
          optional :middle_name, type: String, desc: 'User middle name.'
          optional :suffix, type: String, desc: 'User suffix.'
          optional :user_type, type: String, desc: 'User type.'
          optional :user_role, type: String, desc: 'User role.'
          optional :title, type: String, desc: 'User title.'
          optional :password, type: String, desc: 'User password.'
        end
      end

      resource :users do

        # GET /api/v1/users
        desc 'Return a list of users'
        get do
          users = User.all
          present users, with: Api::V1::Entities::UserEntity
        end

        # POST /api/v1/users
        desc 'Create a new user'
        params do
          use :shared_user_params
          requires :email
          requires :first_name
          requires :last_name
          requires :user_role
          requires :password
        end
        post do
          user_params = declared(params, include_missing: false)
          user = User.new(user_params)
          if user.save
            present user, with: Api::V1::Entities::UserEntity
          else
            error!({ errors: user.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/users/:id
          desc 'Return a specific user'
          get do
            user = User.find(params[:id])
            present user, with: Api::V1::Entities::UserEntity
          end

          # PUT /api/v1/users/:id
          desc 'Update an existing user'
          params do
            use :shared_user_params
          end
          put do
            user = User.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)
            if user.update(update_params)
              present user, with: Api::V1::Entities::UserEntity
            else
              error!({ errors: user.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/users/:id
          desc 'Delete a user'
          delete do
            user = User.find(params[:id])
            if user.destroy
              status 204
              {}
            else
              error!({ errors: user.errors.full_messages }, 422)
            end
          end

        end
      end
    end
  end
end
