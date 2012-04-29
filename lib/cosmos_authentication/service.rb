require "cosmos/service"
require "cosmos_authentication/middleware/use_token"

module CosmosAuthentication
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

    def resource_owner(access_token)
      get_resource_owner(access_token)
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

    def get_resource_owner(access_token)
      output = call(access_token: access_token) do
        use Middleware::UseToken, :access_token
        use Cosmos::Middleware::Discover
        use Cosmos::Middleware::Traverse, 'resource-owners'
        use Cosmos::Middleware::Traverse, 'current'
        use Cosmos::Middleware::Save, :resource_owner
      end

      output[:resource_owner]
    end
  end
end
