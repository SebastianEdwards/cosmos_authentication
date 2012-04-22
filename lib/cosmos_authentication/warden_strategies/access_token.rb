module Cosmos
  module Authentication
    module Warden
      ::Warden::Strategies.add(:access_token) do
        include StrategyMixin

        def valid?
          session[:access_token]
        end

        def authenticate!
          find_user_by_access_token(session[:access_token])
        end
      end
    end
  end
end
