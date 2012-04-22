module Cosmos
  module Authentication
    class Stub
      attr_reader :href

      def initialize(client, klass, href)
        @client = client
        @klass = klass
        @href = href
      end

      def method_missing(method_sym, *args)
        @object ||= @klass.new(@client, @client.get(href).body)
        if @object.respond_to?(method_sym)
          @object.send method_sym, *args
        else
          super
        end
      end
    end
  end
end
