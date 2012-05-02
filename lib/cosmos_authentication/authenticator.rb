module CosmosAuthentication
  class Authenticator
    class UnableToAuthenticate < StandardError; end

    ACCESS_TOKEN_KEY    = 'authentication.access_token'.freeze
    REFRESH_TOKEN_KEY   = 'authentication.refresh_token'.freeze
    AUTH_HEADER_REGEX   = /Bearer\s+(\w+)/i.freeze

    attr_reader :current_resource_owner

    def initialize(service_client, header, request, session, client_id, client_secret)
      @service_client   = service_client
      @header           = header
      @request          = request
      @session          = session
      @client_id        = client_id
      @client_secret    = client_secret
    end

    def authenticate(scope = '')
      load_token_into_session(scope) if session && access_token.nil?
      @current_resource_owner = get_resource_owner if access_token
    rescue Cosmos::UnknownLinkError, Cosmos::FailedCheckError
      unless !session || session[ACCESS_TOKEN_KEY].nil?
        session.delete ACCESS_TOKEN_KEY
        authenticate
      end
    end

    def authenticate!(scope = '')
      authenticate or raise(UnableToAuthenticate.new)
    end

    def authenticated?
      !!current_resource_owner
    end

    def clear_session
      session.delete ACCESS_TOKEN_KEY
      session.delete REFRESH_TOKEN_KEY

      nil
    end

    private
    attr_reader :service_client, :header, :request, :session

    def access_token
      access_token_from_header || access_token_from_session
    end

    def access_token_from_header
      header.match(AUTH_HEADER_REGEX)[1] if header
    end

    def access_token_from_session
      session[ACCESS_TOKEN_KEY] if session
    end

    def get_new_token(scope)
      env = {token_endpoint: token_endpoint}
      if code_grant_available?
        perform_code_grant(env)
      elsif password_grant_available?
        perform_password_grant(env, scope)
      elsif refresh_token_grant_available?
        perform_refresh_token_grant(env, scope)
      end
    end

    def get_resource_owner
      get_resource_owner_document.body
    end

    def get_resource_owner_document
      output = service_client.call do |cosmos|
        cosmos.use Proc.new {|env| (env[:headers] ||= {})['Authentication'] = "Bearer #{access_token}"}
        cosmos.discover
        cosmos.traverse 'resource-owners'
        cosmos.traverse 'current'
        cosmos.check :has_one_item?
        cosmos.save :resource_owner
      end

      output[:resource_owner]
    end

    def load_token_into_session(scope)
      if token = get_new_token(scope)
        session[ACCESS_TOKEN_KEY]   = token['access_token']
        session[REFRESH_TOKEN_KEY]  = token['refresh_token']
      end

      nil
    end

    def token_endpoint
      output = service_client.call do |cosmos|
        cosmos.discover
        cosmos.traverse 'oauth2-token'
        cosmos.save :token_endpoint
      end

      output[:token_endpoint]
    end

    def perform_grant(env)
      output = service_client.call(env) do |cosmos|
        cosmos.load :token_endpoint
        cosmos.submit
        cosmos.save :token_response
      end

      output[:token_response].body
    end

    def code_grant_available?
      request.get? && !!request.params['code']
    end

    def perform_code_grant(env)
      data = {
        client_id:      @client_id,
        client_secret:  @client_secret,
        code:           request.params['code'],
        grant_type:     'code'
      }
      perform_grant env.merge({data: data})
    end

    def password_grant_available?
      request.post? \
      && !!request.params['username'] \
      && !!request.params['password']
    end

    def perform_password_grant(env, scope)
      data = {
        client_id:      @client_id,
        client_secret:  @client_secret,
        grant_type:     'password',
        password:       request.params['password'],
        scope:          scope,
        username:       request.params['username']
      }
      perform_grant env.merge({data: data})
    end

    def refresh_token_grant_available?
      !!session[REFRESH_TOKEN_KEY]
    end

    def perform_refresh_token_grant(env, scope)
      data = {
        client_id:      @client_id,
        client_secret:  @client_secret,
        grant_type:     'refresh_token',
        refresh_token:  session[REFRESH_TOKEN_KEY],
        scope:          scope
      }
      perform_grant env.merge({data: data})
    end
  end
end
