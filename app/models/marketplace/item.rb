module Marketplace
  class Item

    # static variables: list with all existing items in the whole system and an id for a unique identification
    @@items = []
    @@id = 1

    attr_accessor :id, :name, :price, :owner, :active, :quantity

    # constructor
    # @param [String] name of the new item
    # @param [Float] price of the new item
    # @param [Integer] quantity of the new item
    # @param [User] owner of the new item
    # @return [Item] created item
    def self.create(name, price, quantity, owner)
      item = self.new
      item.id = @@id
      @@id += 1
      item.name = name
      item.price = price
      item.quantity = quantity
      item.owner = owner
      owner.add_item(item)
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

    # removes this item from the static item list
    # and from the current owner
    def remove
      self.owner.remove_item(self)
      @@items.remove self
    end

    # splits the item into two seperate items
    # this items quantity will be 'at' and the
    # new created items quantity will be the rest
    # @param [Integer] index where to split the item
    # @return [Item] new item with quantity 'rest'
    def split(at)
      if self.quantity >= at
        throw RangeError
      else
        rest = self.quantity - at
        self.quantity = rest
        Item.create(self.name, self.price, at, self.owner)
      end
    end

    # merges two similar items together

    def merge(item)
      if mergeable?(item)
        self.quantity = self.quantity + item.quantity
        item.remove
      else
        throw TypeError
      end
    end

    # checks if two items are similar
    def mergeable?(item)
      if self.name == item.name and
         self.price == item.price and
         self.owner == item.owner
      end
    end

    def activate
      self.active = true
    end

    def deactivate
      self.active = false
    end

    def to_s
      "Name: #{name} Price:#{self.price} Quantity:#{self.quantity} Active:#{self.active} Owner:#{self.owner.name}"
    end

  end
end