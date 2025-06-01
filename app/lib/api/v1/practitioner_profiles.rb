module Api
  module V1
    class PractitionerProfiles < Grape::API

      helpers do
        params :shared_practitioner_profile_params do
          requires :provider_id, type: Integer, desc: 'Associated provider ID'
          optional :bio, type: String, desc: 'Practitioner biography'
          optional :website, type: String, desc: 'Practitioner website'
        end
      end

      resource :practitioner_profiles do

        # GET /api/v1/practitioner_profiles
        desc 'Return all practitioner profiles'
        get do
          profiles = PractitionerProfile.all
          present profiles, with: Api::V1::Entities::PractitionerProfileEntity
        end

        # POST /api/v1/practitioner_profiles
        desc 'Create a practitioner profile'
        params do
          use :shared_practitioner_profile_params
        end
        post do
          profile = PractitionerProfile.new(declared(params, include_missing: false))

          if profile.save
            present profile, with: Api::V1::Entities::PractitionerProfileEntity
          else
            error!({ errors: profile.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/practitioner_profiles/:id
          desc 'Return a specific practitioner profile'
          get do
            profile = PractitionerProfile.find(params[:id])
            present profile, with: Api::V1::Entities::PractitionerProfileEntity
          end

          # PUT /api/v1/practitioner_profiles/:id
          desc 'Update a practitioner profile'
          params do
            use :shared_practitioner_profile_params
          end
          put do
            profile = PractitionerProfile.find(params[:id])
            update_params = declared(params, include_missing: false)

            if profile.update(update_params)
              present profile, with: Api::V1::Entities::PractitionerProfileEntity
            else
              error!({ errors: profile.errors.full_messages }, 422)
            end
          end

          # DELETE /api/v1/practitioner_profiles/:id
          desc 'Delete a practitioner profile'
          delete do
            profile = PractitionerProfile.find(params[:id])
            if profile.destroy
              status 204
              {}
            else
              error!({ errors: ['Failed to delete practitioner profile'] }, 500)
            end
          end

        end
      end
    end
  end
end
