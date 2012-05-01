require "cosmos/service"
require "cosmos_authentication/resource_owner"
require "cosmos_authentication/middleware/use_token"

module CosmosAuthentication
  class Service < Cosmos::Service
    attr_accessor :client_id, :client_secret
    attr_writer :resource_owner_class

    def default_env
      super.merge({
        data: {
          client_id:      client_id,
          client_secret:  client_secret
        }
      })
    end

    def get_token_via_code(code)
      get_token({
        client_id:      client_id,
        client_secret:  client_secret,
        grant_type:     'code',
        code:           code
      })
    end

    def get_token_via_password(username, password, scope = '')
      get_token({
        client_id:      client_id,
        client_secret:  client_secret,
        grant_type:     'password',
        username:       username,
        password:       password,
        scope:          scope
      })
    end

    def get_token_via_refresh_token(refresh_token, scope = '')
      get_token({
        client_id:      client_id,
        client_secret:  client_secret,
        grant_type:     'refresh_token',
        refresh_token:  refresh_token
      })
    end

    def providers
      get_providers
    end

    def resource(resource_name, access_token, resource_owner)
      get_resource(resource_name, access_token, resource_owner)
    end

    def resource_owner(access_token)
      resource_owner_class.new.tap do |resource_owner|
        resource_owner.collection = get_resource_owner(access_token)
      end
    end

    def resource_owner_class
      @resource_owner_class || ResourceOwner
    end

    private
    def get_token(data)
      output = call(data: data) do
        use Cosmos::Middleware::Discover
        use Cosmos::Middleware::Traverse, 'oauth2-token'
        use Cosmos::Middleware::Submit
        use Cosmos::Middleware::Save, :token
      end

      output[:token]
    end

    def get_providers
      output = call do
        use Cosmos::Middleware::Discover
        use Cosmos::Middleware::Traverse, 'providers'
        use Cosmos::Middleware::Save, :providers
      end

      output[:providers]
    end

    def get_resource(resource_name, access_token, resource_owner)
      env = {access_token: access_token, resource_owner: resource_owner}
      output = call(env) do
        use Middleware::UseToken, :access_token
        use Cosmos::Middleware::Load, :resource_owner
        use Cosmos::Middleware::Traverse, 'resource'
        use Cosmos::Middleware::Check, :has_items?
        use Cosmos::Middleware::Save, :resource
      end

      output[:resource]
    end

    def get_resource_owner(access_token)
      output = call(access_token: access_token) do
        use Middleware::UseToken, :access_token
        use Cosmos::Middleware::Discover
        use Cosmos::Middleware::Traverse, 'resource-owners'
        use Cosmos::Middleware::Traverse, 'current'
        use Cosmos::Middleware::Check, :has_one_item?
        use Cosmos::Middleware::Save, :resource_owner
      end

      output[:resource_owner]
    end
  end
end
