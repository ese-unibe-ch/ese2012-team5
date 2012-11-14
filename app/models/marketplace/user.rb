module Marketplace

  class User

    attr_accessor :name, :credits, :items, :picture, :password,
                  :email, :details, :verified

    # constructor with password
    # @param [String] name of the new user
    # @param [String] email address
    # @param [String] password of the new user
    # @return [Item] created item
    def self.create(name, password,email)
      user = self.new
      user.name = name
      user.email = email
      user.password = BCrypt::Password.create(password)
      user
    end

    # initial properties of a user
    def initialize
      self.credits = 100
      self.picture = "default_profile.jpg"
      self.details = "nothing"
      self.items = Array.new
      self.verified = false
    end

    def enough_credits(amount)
      self.available_credits >= amount
    end

    # credits a user can currently spend, not including credits that are frozen in auctions
    def available_credits
      self.credits - self.frozen_credits
    end

    # gets sum of credits that are currently frozen in highest bids on auctions
    def frozen_credits
      #if the user is not highest bidder on any auctions, return 0
      return 0 if Marketplace::Auction.get_auctions_by_user(self).size == 0
      frozen_credits = 0
      Marketplace::Auction.get_auctions_by_user(self).each { | auction | frozen_credits += auction.current_winning_price }
      return frozen_credits
    end

    def change_password(password)
      self.password = BCrypt::Password.create(password)
    end

    # @param [Item] item the user want to buy
    def buy(item)
      raise "cannot buy an item in auction mode" if item.is_in_auction_mode?
      if self.enough_credits(item.price * item.quantity) && item.active
        item.owner.sell(item)
        item.owner = self
        self.remove_credits(item.price * item.quantity)
        self.add_item(item)
        item.deactivate
      else
        raise "cannot by item"
      end
    end

    # @param [Item] item the user want to sell
    # this is called internally for the seller when another user buys his item
    def sell(item)
      self.remove_item(item)
      self.add_credits(item.price * item.quantity)
    end

    # @param [Float] amount which the user gets additionally
    def add_credits(amount)
      self.credits += amount
    end

    # @param [Float] amount which the user loses
    def remove_credits(amount)
      self.credits -= amount
    end

    # @param [Item] item item is added to the users item-list
    def add_item(item)
      self.items.push(item)
    end

    # @param [Item] item item is removed from the users item-list
    def remove_item(item)
      self.items.delete(item)
    end

    # @param [Item] item checks if the user owns this item
    # @return [Boolean] True if the item is part of the users item-list
    def has_item?(item)
      !(self.items.detect do |item_temp|
        item_temp.id == item.id
      end.nil?)
    end

    # @param [Item] item item to buy
    # @param [Integer] quantity how much of the item
    # @return [Boolean] True if user has enough credits, is not owner and item is active
    def can_buy_item?(item, quantity)
      if item.is_in_auction_mode?
        self.name != item.owner and
            enough_credits(item.get_auction_selling_price) and
            item.active
      else
        self.name != item.owner and
            enough_credits(item.price * quantity) and
            item.active
      end
    end

    def delete
      self.items.each { |item| item.delete}
    end

    def to_s
      "Name: #{name} Credits:#{self.credits} Items:#{self.items}"
    end

    def verify
       self.verified = true
    end

  end

end