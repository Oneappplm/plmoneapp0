# app/lib/api/v1/settings.rb

module Api
  module V1
    class Settings < Grape::API

      helpers do
        params :shared_setting_params do
          optional :theme_color, type: String, desc: 'Selected theme color.'
          optional :font_style, type: String, desc: 'Selected font style.'
          optional :logo_file, type: String, desc: 'Path/reference to the logo file.'
          optional :dark_mode, type: String, desc: 'Dark mode status (e.g., "YES", "NO").'
          optional :client_name, type: String, desc: 'Name of the client.'
          optional :enable_otp, type: Boolean, desc: 'Flag to enable/disable OTP.'
        end
      end

      resource :settings do

        # GET /api/v1/settings
        desc "Return a list of setting records"
        get do
          settings = Setting.all
          present settings, with: Api::V1::Entities::SettingEntity
        end

        # POST /api/v1/settings
        desc "Create a setting record"
        params do
          use :shared_setting_params
        end
        post do
          setting_params = declared(params, include_missing: false)
          setting = Setting.new(setting_params)

          if setting.save
            present setting, with: Api::V1::Entities::SettingEntity
          else
            error!({ errors: setting.errors.full_messages }, 422)
          end
        end

        route_param :id do

          # GET /api/v1/settings/:id
          desc "Return a specific setting record"
          get do
            setting = Setting.find(params[:id])
            present setting, with: Api::V1::Entities::SettingEntity
          end

          # PUT /api/v1/settings/:id
          desc "Update a specific setting record"
          params do
            use :shared_setting_params
          end
          put do
            setting = Setting.find(params[:id])
            update_params = declared(params, include_missing: false).except(:id)

            if setting.update(update_params)
              present setting, with: Api::V1::Entities::SettingEntity
            else
              error!({ errors: setting.errors.full_messages }, 422)
            end
          end

        end
      end
    end
  end
end
