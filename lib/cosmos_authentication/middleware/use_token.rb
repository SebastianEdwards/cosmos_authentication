module CosmosAuthentication
  module Middleware
    class UseToken
      def initialize(app, key = :current_body)
        @app = app
        @key = key
      end

      def call(env)
        access_token = env[@key]['access_token']
        header = {'Authentication' => "Bearer #{access_token}"}
        env[:client].tap { |client| client.headers.merge!(header) }
        @app.call env
      end
    end
  end
end
