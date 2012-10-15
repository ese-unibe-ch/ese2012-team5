module Marketplace
  class Item

    # static variables: list with all existing items in the whole system and an id for a unique identification
    @@items = []
    @@id = 1

    attr_accessor :id, :name, :price, :owner, :active, :quantity

    # constructor
    # @param [String] name of the new item
    # @param [Float] price of the new item
    # @param [User] owner of the new item
    # @return [Item] created item
    def self.create(name, price, owner)
      item = self.new
      item.id = @@id
      @@id += 1
      item.name = name
      item.price = price
      item.owner = owner
      owner.add_item(item)
      quantity = 1
      item.save
      item
    end

    # initial property of an item
    def initialize
      self.active = false
    end

    # @param [Integer] ID of the desired item
    # @return [Item] desired item
    def self.by_id(id)
      @@items.detect{|item| item.id == id}
    end

    # @return [Array] all items of the whole system
    def self.all
      @@items
    end

    # save this item to the static item list
    def save
      @@items << self
    end

    def activate
      self.active = true
    end

    def deactivate
      self.active = false
    end

    def delete
      @@items.delete(self)
    end

    def to_s
      "Name: #{name} Price:#{self.price} Active:#{self.active} Owner:#{self.owner.name}"
    end

  end
end