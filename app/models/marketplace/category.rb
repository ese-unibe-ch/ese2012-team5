module Marketplace

  # Category class that acts like an intelligent data wrapper around an array of items with the same name.
  # It stores attributes that are needed in various haml views and prevents those views from having too much logic.
  # Works in strong cooperation with the categorizer helper module.
  class Category

    attr_accessor :items, :name, :min_price, :owners, :quantity

    # Constructor that creates new category
    # @param [Item] item around which the new category should be created
    # @return [Category] category object
    def self.create(item)
      category = self.new
      category.items.push(item)
      category.name = item.name
      category.min_price = item.price.to_i
      category.owners.push(item.owner)
      category.quantity = item.quantity
      category
    end

    # Initial property of a category.
    def initialize
      self.items = Array.new
      self.owners = Array.new
    end

    # Adds an item to the category an updates attributes where required
    # @param [Item] item to add
    # @return [Category] category with item
    def add(item)
      raise NotImplementedError if item.name != self.name
          self.items.push(item)
      if self.min_price > item.price.to_i
        self.min_price = item.price.to_i
      end
      self.owners.push(item.owner)
      self.owners = self.owners.uniq
      self.quantity += item.quantity
      self
    end

    # @return [String] image_path to image tha represents category.
    def front_image
      self.items.first.image_path(0)
    end

    # @return [Integer] amount of different owners of an item of this category.
    def owner_count
      owners.length
    end

    # @return [Integer] total amount of different items in this category.
    # not to be mistaken with total quantity!
    def item_count
      items.length
    end

    # @return [Boolean] true if there are more than one owners in this category.
    def has_multiple_owners
      self.owners.length > 1
    end

    # @return [Boolean] true if there are more than one items in this category.
    def has_multiple_items
      self.items.length > 1
    end

  end

end