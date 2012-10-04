module Marketplace
  class Item

    # every item has a id
    # every item has a owner
    # items contains all items

    @@items = Array.new

    attr_accessor :id, :name, :price, :owner, :active


    def create(name, price, owner)
    end

    def initialize
    end

    def self.by_id(id)
    end

    def self.all
      @@items
    end

    def activate
    end

    def deactivate
    end

    def to_s
      "Name: #{name} Price:#{self.price} Active:#{self.active} Owner:#{self.owner.name}"
    end

  end
end