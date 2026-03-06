module Api
  module Helpers
    module Authentication

      def authenticate!
        validate_oauth_token!
      end

      def validate_oauth_token!
        auth_header = headers['Authorization']
        token_string = auth_header&.split(' ')&.last

        token = Doorkeeper::AccessToken.by_token(token_string)

        unless token&.accessible?
          error!({ error: 'Unauthorized. Invalid OAuth token.' }, 401)
        end

        @current_user = User.find(token.resource_owner_id)
      end

      def current_user
        @current_user
      end

    end
  end
end