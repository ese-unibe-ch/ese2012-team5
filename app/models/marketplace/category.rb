module Marketplace

  class Category

    attr_accessor :items, :name, :min_price, :owners, :quantity

    # Constructor that will automatic add new item to database
    # @param [String] name of the new item
    # @param [Float] min_price of the new item
    # @param [Integer] quantity of the new item
    # @param [User] owner of the new item
    # @return [Item] created item
    def self.create(item)
      category = self.new
      category.items = Array.new
      category.items.push(item)
      category.name = item.name
      category.min_price = item.price
      category.owners = Array.new
      category.owners.push(item.owner)
      category.quantity = item.quantity
      category
    end

    def add(item)
      self.items.push(item)
      if self.min_price > item.price
        self.min_price = item.price
      end
      self.owners.push(item.owner)
      self.quantity += item.quantity
    end
  end

end