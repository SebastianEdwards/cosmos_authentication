module Cosmos
  module Authentication
    module Warden
      module StrategyMixin
        def service
          Cosmos::Authentication.warden_service
        end

        def resource_owner(access_token)
          service.resource_owner access_token
        end

        def find_user_by_access_token(access_token)
          if ro = resource_owner(access_token)
            success!(ro)
          else
            session[:access_token] = nil
          end
        end
      end

      require "cosmos_authentication/warden_strategies/access_token"
      require "cosmos_authentication/warden_strategies/code"
      require "cosmos_authentication/warden_strategies/password"
      require "cosmos_authentication/warden_strategies/refresh_token"
    end
  end
end
