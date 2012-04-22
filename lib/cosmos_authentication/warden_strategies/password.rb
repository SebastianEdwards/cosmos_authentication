module Cosmos
  module Authentication
    module Warden
      ::Warden::Strategies.add(:password) do
        include StrategyMixin

        def valid?
          params[:username] && params[:password]
        end

        def authenticate!
          args = [params[:username], params[:password]]
          if token = service.get_token_with_username_and_password(*args)
            session[:refresh_token] = token['refresh_token']
            session[:access_token]  = token['access_token']
          end
        end
      end
    end
  end
end
