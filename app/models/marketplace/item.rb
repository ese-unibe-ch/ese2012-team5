module Marketplace
  class Bid
    attr_accessor :bidder, # a User,
                  :maximal_price # a real value
  end

  class Item



    # static variables: id for a unique identification
    @@id = 1

    attr_accessor :id, :name,
                  :price, # minimal price for auction mode
                  :owner, :active, :quantity, :pictures,
                  :bids, # an array of Bids
                  :auction_end_time, # a ruby Time object. nil if this object is not in auction mode
                  :increment # for auction mode

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
      item.active = 0
      item.bids = []
      item.increment = 1
      item.auction_end_time = nil
      owner.add_item(item)
      item
    end

    # auction implementation, see specs at https://github.com/ese-unibe-ch/ese2012-wiki/wiki/Intermezzo

    def is_in_auction_mode?
      return self.active && self.auction_end_time != nil
    end

    # items can only be editied if they are not in auction mode or have no bids
    def can_be_deactivated?
      return !self.is_in_auction_mode? || self.bids.length == 0
    end

    # does nothing if not in auction mdoe
    def update_auction_state
      return unless self.is_in_auction_mode? && self.auction_end_time <= Time.now

      # Auction over
      print "Auction ended\n"

      if self.bids.length == 0
        print "No bids\n"
        self.deactivate # If there was no bidder (n=0), the auction simply closes.
        return
      end

      # sell if there's a bidder
      # At the time the auction terminates and there was at least one bidder (n>0), the transaction proceeds in accordance with the current winner and the current selling price at that time. The winner receives a confirmation email.

      self.price = self.get_auction_selling_price
      wnr = self.get_auction_current_winner
      self.bids = []
      self.auction_end_time = nil
      wnr.buy(self) # <<^^can only buy if no longer in auction mode

      # TODO send confirmation email to winner
    end

    # nil if there's none
    def get_auction_current_winner
      return nil if self.bids.length == 0
      return get_auction_current_winning_bid.bidder
    end

    def get_auction_current_winning_bid
      return nil if self.bids.length == 0
      return self.get_bids_ascening.last
    end

    # must be in auction mdoe
    def get_auction_selling_price
      raise "not in auction mode" unless self.is_in_auction_mode?
      if self.bids.length <= 1 # sell for initial price if there's only one bidder
        return self.price
      end

      return self.get_bids_ascening.last(2)[0].maximal_price + self.increment # the current selling price is defined as MP(n-1)+increment.
    end

    # must be in auction mode
    def get_bids_ascening
      raise "not in auction mode" unless self.is_in_auction_mode?
       # http://ariejan.net/2007/01/28/ruby-sort-an-array-of-objects-by-an-attribute
      return self.bids.sort { |a,b| a.maximal_price <=> b.maximal_price }
    end

    # The maximal price of the bid must be >= the minimal price defined in the auction.
    # two bidders cannot have the same maximal price AND
    # a bid cannot be between self.get_auction_current_winning_bid.maximal_price +- self.increment
    # because this would cause the current selling price to become a value that neither the current winner nor the new bidder is ready to pay
    def auction_can_place_bid?(maximal_price)
      return false if !self.is_in_auction_mode? || maximal_price < self.price
      return true if self.bids.length == 0

      bid = self.bids.detect{ |b| b.maximal_price == maximal_price}
      return false if bid != nil

      return false if maximal_price < self.get_auction_current_winning_bid.maximal_price + self.increment &&
                      maximal_price > self.get_auction_current_winning_bid.maximal_price - self.increment

      return true
    end

    # returns false if the bid could not be placed beacuse it was not an increase
    def auction_place_bid(maximal_price, bidder)
      raise "cannot place that bid" unless self.auction_can_place_bid?(maximal_price)

      if self.bids.length > 0 && self.get_auction_current_winning_bid.bidder == bidder
        # just increase old max value if bigger than it
        if maximal_price < self.get_auction_current_winning_bid.maximal_price
          return false
        end
        self.get_auction_current_winning_bid.maximal_price = maximal_price
      else
        # create new
        bid = Bid.new
        bid.bidder = bidder
        bid.maximal_price = maximal_price

        if self.get_auction_current_winner
          # TODO send the notification mail to the old winner (self.get_auction_current_winner) since we have a new (if it were the same, we would be in the "if", not the "else" brach)
        end

        self.bids << bid

      end
      return true
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
        throw NotImplementedError
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