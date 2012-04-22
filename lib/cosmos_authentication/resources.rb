module Cosmos
  module Authentication
    class Resources
      def initialize(client, collection)
        @client = client
        @collection = collection
      end

      def has_resource?(uri)
        matches = @collection.items.select do |item|
          item.href == uri
        end.length > 0
      end

      def all
        @collection.items.map do |item|
          Stub.new(@client, Resource, item.href)
        end
      end
    end

    class Resource
      def initialize(client, collection)
        @client = client
        @collection = collection
      end
    end
  end
end
