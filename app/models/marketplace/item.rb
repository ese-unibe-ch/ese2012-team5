module Marketplace

  class Item

    # static variables: id for a unique identification
    @@id = 1

    attr_accessor :id,
                  :name,
                  :price,
                  :owner,
                  :active,
                  :quantity,
                  :pictures,
                  :auction

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
      item
    end

    def is_in_auction_mode?
      return self.auction != nil
    end

    def update_auction
      self.auction.update if self.is_in_auction_mode?
    end

    def close_auction
      self.price = auction.current_winning_price
      self.auction = nil
    end

    # items can only be editied if they are not in auction mode or have no bids
    def can_be_deactivated?
      return !self.is_in_auction_mode? || !self.auction.has_bids?
    end

    # initial property of an item
    def initialize
      self.active = false
    end

    # splits the item into two separate items
    # this items quantity will be 'at' and the
    # new created items quantity will be the rest
    # @param [Integer] index where to split the item
    # @return [Item] new item with quantity 'rest'
    def split(at)
      if self.quantity < at
        raise ArgumentError
      else
        rest = self.quantity - at
        self.quantity = rest
        item = Item.create(self.name, self.price, at, self.owner)
        Marketplace::Database.instance.add_item(item)
        item.activate
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

    def activate
      self.active = true
    end

    def deactivate
      self.active = false
    end

    def switch_active
      self.active = !self.active
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

  end

end