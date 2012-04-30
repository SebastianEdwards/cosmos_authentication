require 'cosmos_authentication/service'

module CosmosAuthentication
  class RackMiddleware
    class Authenticator
      attr_reader :current

      def initialize(opts, env)
        @opts = opts
        @env  = env
      end

      def authenticate(scope = '')
        begin
          token = access_token(scope)
          @current = service.resource_owner(token)
        rescue Cosmos::UnknownLinkError, Cosmos::FailedCheckError
          session[:access_token] = nil
          authenticate
        end

        nil
      end

      def logged_in?
        !!current
      end

      def logout
        session[:access_token]   = nil
        session[:refresh_token]  = nil

        nil
      end

      private
      def access_token(scope)
        unless token = access_token_from_header
          ensure_token(scope)
          token = access_token_from_session
        end

        token
      end

      def access_token_from_header
        if has_header? && match = header.match(/Bearer\s+(\w+)/i)
          {'access_token'  => match[1]}
        end
      end

      def access_token_from_session
        {'access_token'  => session[:access_token]}
      end

      def code_available?
        request.get? && !!params['code']
      end

      def get_token(scope)
        if code_available?
          service.get_token_via_code(params['code'])
        elsif password_available?
          service.get_token_via_password(
            params['username'],
            params['password'],
            scope
          )
        elsif refresh_token_available?
          service.get_token_via_refresh_token(
            session[:refresh_token],
            scope
          )
        end
      end

      def ensure_token(scope)
        unless session[:access_token]
          if token = get_token(scope)
            session[:access_token]   = token['access_token']
            session[:refresh_token]  = token['refresh_token']
          end
        end
      end

      def has_header?
        !!header
      end

      def header
        @env['HTTP_AUTHENTICATION']
      end

      def params
        request.params
      end

      def password_available?
        request.post? && !!params['username'] && !!params['password']
      end

      def refresh_token_available?
        !!session[:refresh_token]
      end

      def request
        @req ||= Rack::Request.new(@env)
      end

      def session
        @env['rack.session']
      end

      def service
        @service ||= Service.new do |config|
          config.client_id      = @opts[:client_id]
          config.client_secret  = @opts[:client_secret]
          config.endpoint       = @opts[:endpoint]
          config.cache          = @opts[:cache] if @opts[:cache]
          if @opts[:resource_owner_class]
            config.resource_owner_class = @opts[:resource_owner_class]
          end
        end
      end
    end

    def initialize(app, opts = {})
      @app  = app
      @opts = opts
    end

    def call(env)
      env['authentication'] = Authenticator.new(@opts, env)
      @app.call env
    end
  end
end
