module Cosmos
  module Authentication
    module Warden
      ::Warden::Strategies.add(:refresh_token) do
        include StrategyMixin

        def valid?
          session[:refresh_token]
        end

        def authenticate!
          if token = service.get_token_with_refresh_token(session[:refresh_token])
            session[:refresh_token] = token['refresh_token']
            session[:access_token]  = token['access_token']
            find_user_by_access_token(session[:access_token])
          end
        end
      end
    end
  end
end
