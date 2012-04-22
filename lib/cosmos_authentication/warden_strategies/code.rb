module Cosmos
  module Authentication
    module Warden
      ::Warden::Strategies.add(:code) do
        include StrategyMixin

        def valid?
          params[:code]
        end

        def authenticate!
          if token = service.get_token_with_code(params[:code])
            session[:refresh_token] = token['refresh_token']
            session[:access_token] = token['access_token']
          end
        end
      end
    end
  end
end
