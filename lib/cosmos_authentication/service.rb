require "cosmos/service"
require "cosmos_authentication/resource_owner"

module Cosmos
  module Authentication
    class Service < Cosmos::Service
      attr_accessor :client_id, :client_secret
      attr_writer :resource_owner_class

      def client_with_credentials
        raise "No credentials configured." unless client_id && client_secret
        @client_with_credentials ||= client.dup.tap do |client|
          client.params['client_id'] = client_id
          client.params['client_secret'] = client_secret
        end
      end

      def client_with_token(access_token)
        client.dup.tap do |client|
          client.headers['Authentication'] = "Bearer #{access_token}"
        end
      end

      def get_token_with_code(code)
        client = client_with_credentials
        response = client.post token_link.href, {
          grant_type:     'code',
          code:           code
        }
        response.body
      end

      def get_token_with_refresh_token(refresh_token)
        client = client_with_credentials
        response = client.post token_link.href, {
          :grant_type => 'refresh_token',
          :refresh_token => refresh_token
        }
        response.body
      end

      def get_token_with_username_and_password(username, password, scope = '')
        client = client_with_credentials
        response = client.post token_link.href, {
          :grant_type       => 'password',
          :username         => username,
          :password         => password,
          :scope            => 'manage_companies'
        }
        response.body
      end

      def resource_owner(access_token)
        client = client_with_token(access_token)
        href = endpoint.link('resource_owner').href
        response = client.get(href).body
        if response.items.length > 0
          response = client.get(response.items.first.href).body
          resource_owner_class.new(client, response)
        end
      end

      def resource_owner_class
        @resource_owner_class || ResourceOwner
      end

      def token_link
        endpoint.link('oauth2_token')
      end

      def use_for_warden_authentication
        Cosmos::Authentication.warden_service self
      end
    end
  end
end
