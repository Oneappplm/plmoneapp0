module Api
  module V1
    module Entities
      class SettingEntity < Grape::Entity
        expose :id, documentation: { type: 'Integer', desc: 'Unique ID of the setting record.' }
        expose :theme_color, documentation: { type: 'String', desc: 'Selected theme color.' }
        expose :font_style, documentation: { type: 'String', desc: 'Selected font style.' }
        expose :logo_file, documentation: { type: 'String', desc: 'Path/reference to the logo file.' }
        expose :dark_mode, documentation: { type: 'String', desc: 'Dark mode status (e.g., "YES", "NO").' }
        expose :client_name, documentation: { type: 'String', desc: 'Name of the client.' }
        expose :enable_otp, documentation: { type: 'Boolean', desc: 'Flag to enable/disable OTP.' }
        expose :created_at, documentation: { type: 'DateTime', desc: 'Timestamp created.' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Timestamp updated.' }
      end
    end
  end
end
