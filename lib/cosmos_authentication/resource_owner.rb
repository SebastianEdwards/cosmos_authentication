require "cosmos_authentication/stub"
require "cosmos_authentication/resources"

module Cosmos
  module Authentication
    class ResourceOwner
      def initialize(client, collection)
        @client = client
        @collection = collection
      end

      def data
        @data ||= @collection.items.first.data.inject({}) do |hash, data|
          hash.merge!({data.name => data.value})
        end
      end

      def resources
        @resources ||= @collection.links.inject({}) do |hash, link|
          hash.merge!({link.rel => Stub.new(@client, Resources, link.href)})
        end
      end
    end
  end
end
