module CosmosAuthentication
  class ResourceOwner
    attr_accessor :collection

    extend Forwardable
    def_delegators :item, :data, :datum, :href, :link, :links

    private
    def item
      @item ||= @collection.items.first
    end
  end
end
