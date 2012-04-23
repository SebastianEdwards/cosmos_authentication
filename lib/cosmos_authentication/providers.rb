module Cosmos
  module Authentication
    class Providers
      def initialize(client, collection)
        @client = client
        @collection = collection
      end

      def all
        @collection.queries.map {|query| Provider.new(@client, query)}
      end

      def find(rel)
        query = @collection.queries.select {|query| query.rel == rel}.first
        Provider.new(@client, query)
      end
    end

    class Provider
      extend Forwardable
      def_delegator :@query, :rel, :name
      def_delegators :@query, :build, :prompt

      def initialize(client, query)
        @client = client
        @query = query
      end
    end
  end
end
