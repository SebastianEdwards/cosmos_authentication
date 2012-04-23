require "cosmos_authentication/version"
require "cosmos_authentication/service"
require "cosmos_authentication/warden" if defined? Warden

module Cosmos
  module Authentication
    def self.warden_service(service = nil)
      @warden_service = service unless service.nil?
      @warden_service || raise('No authentication service configured for warden.'.inspect)
    end
  end
end
