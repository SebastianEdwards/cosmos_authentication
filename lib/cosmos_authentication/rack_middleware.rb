require 'cosmos_authentication/authenticator'

module CosmosAuthentication
  class RackMiddleware
    def initialize(app, opts = {})
      @app            = app
      @session_key    = opts.delete(:session_key) || 'rack.session'
      @client_id      = opts.delete(:client_id)
      @client_secret  = opts.delete(:client_secret)
    end

    def call(env)
      env['authentication'] = Authenticator.new \
        env['cosmos'],                          \
        env['HTTP_AUTHENTICATION'],             \
        Rack::Request.new(env),                 \
        env[@session_key],                      \
        @client_id,                             \
        @client_secret
      @app.call env
    end
  end
end
