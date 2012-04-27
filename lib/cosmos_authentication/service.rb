require "cosmos/service"

module Cosmos
  module Authentication
    class Service < Cosmos::Service
      attr_accessor :client_id, :client_secret

      def default_env
        super.merge({
          data: {
            client_id:      client_id,
            client_secret:  client_secret
          }
        })
      end

      def get_token_via_password(username, password)
        data
        output = SERVICE.call(data: data) do
          use Middleware::Discover
          use Middleware::Save, :root
          use Middleware::Traverse, 'oauth2-token'
          use Middleware::Submit
          use Middleware::Save, :token
        end

        output[:token]
      end
    end
  end
end
