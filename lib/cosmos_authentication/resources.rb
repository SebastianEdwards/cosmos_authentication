module Cosmos
  module Authentication
    class Resources
      def initialize(client, collection)
        @client = client
        @collection = collection
      end

      def has_resource?(uri)
        all.select do |item|
          item.href == uri
        end.length > 0
      end

      def first
        all.first
      end

      def all
        @resources ||= @collection.items.map do |item|
          Stub.new(@client, Resource, item.href)
        end
      end
    end

    class Resource
      extend Forwardable
      def_delegator :@collection, :items

      def initialize(client, collection)
        @client = client
        @collection = collection
      end
    end
  end
end
