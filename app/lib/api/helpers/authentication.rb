module Api
  module Helpers
    module Authentication
      def authenticate!
        api_key = Rails.application.credentials.dig(:rest_api_key)
        
        unless api_key.present? && headers['X-Api-Key'] == api_key
          error!('Unauthorized. Invalid API Key.', 401)
        end
      end
    end
  end
end
