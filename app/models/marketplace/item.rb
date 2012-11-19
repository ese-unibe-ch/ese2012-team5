module Marketplace

  class Item

    # static variables: id for a unique identification
    @@id = 1

    attr_accessor :id, :name, :price, :owner, :active, :quantity, :pictures

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
      item.pictures = Array.new
      owner.add_item(item)
      Marketplace::Database.instance.add_item(item)
      item
    end

    # initial property of an item
    def initialize
      self.active = false
    end

    # splits the item into two separate items
    # this items quantity will be 'at' and the
    # new created items quantity will be the rest
    # @param [Integer] at where to split the item
    # @return [Item] new item with quantity 'at'
    def split(at)
      if self.quantity < at
        throw NotImplementedError
      else
        rest = self.quantity - at
        self.quantity = rest
        item = Item.create(self.name, self.price, at, self.owner)
        item.active = true #NOTE by urs: do not use item.activate or you start the buyOrder listeners!
        item
      end
    end

    # merges two similar items together
    def merge(item)
      if mergeable?(item)
        self.quantity = self.quantity + item.quantity
        Marketplace::Database.instance.delete_item(item)
      else
        throw TypeError
      end
    end

    # checks if two items are similar
    def mergeable?(item)
      self.name == item.name and self.price == item.price
    end

    # Activates item and fires Item to all buy_order listener
    # If you don't want to fire the Event use "item.active = true" instead!
    def activate
      self.active = true
      Marketplace::Database.instance.call_buy_orders(self)
    end

    def deactivate
      self.active = false
    end

    def switch_active
      if self.active
        self.deactivate
      else
          self.activate
      end
    end

    # append image at the end
    def add_image(url)
        self.pictures.push(url)
    end

    # remove image at position
    # @param [Integer] position
    def del_image_by_nr(nr)
      self.pictures.delete_at(nr)
      self.pictures.reject{ |c| c.empty? }
    end

    # move image to position 0 (profile)
    # @param [Integer] position
    def move_image_to_front (nr)
      temp = self.pictures.at(0)
      self.pictures[0] = self.pictures[nr]
      self.pictures[nr] = temp
    end

    def delete
      self.owner.remove_item(self)
    end

    def to_s
      "Name: #{name} Price:#{self.price} Quantity:#{self.quantity} Active:#{self.active} Owner:#{self.owner.name}"
    end


    def image_path(index)
      if self.pictures[index] == nil
        return File.join("", "images", "default_item.jpg")
      else
        return File.join("", "images", self.pictures[index])
      end
      puts "error?"
    end

  end

end