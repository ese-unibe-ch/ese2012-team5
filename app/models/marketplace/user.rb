module Marketplace
  class User

    # static class variable: list with all existing users in the whole system
    @@users = []

    attr_accessor :name, :credits, :items, :picture, :password, :email, :interests

    # constructor with password
    # @param [String] name of the new user
    # @param [String] password of the new user
    # @return [Item] created item
    def self.create(name, password)
      user = self.new
      user.name = name
      user.password = BCrypt::Password.create(password)
      user.interests = ""
      user
    end

    # initial properties of a user
    def initialize
      self.credits = 100
      self.picture = "default_profile.jpg"
      self.details = "nothing"
      self.items = Array.new
    end

    # @param [String] name the desired user
    # @return [User] desired user
    def self.by_name(name)
      @@users.detect{|user_temp| user_temp.name == name}
    end

    # @return [Array] all users of the whole system
    def self.all
      @@users
    end

    # save this user to the static user list
    def save
      @@users << self
    end

    # updates interests of user
    def update_interests(interests)
      self.interests = interests
    end

    def enough_credits(amount)
      self.credits >= amount
    end

    # @param [Item] item the user want to buy
    def buy(item)
      if self.enough_credits(item.price)  && item.active
        self.remove_credits(item.price)
        item.owner.sell(item)
        item.owner = self
        self.add_item(item)
        item.deactivate
      end
    end

    # @param [Item] item the user want to sell
    def sell(item)
      self.remove_item(item)
      self.add_credits(item.price)
    end

    # @param [Float] amount which the user gets additionally
    def add_credits(amount)
      self.credits += amount
    end

    # @param [Float] amount which the user loses
    def remove_credits(amount)
      self.credits -= amount
    end

    # @param [Item] this item is added to the users item-list
    def add_item(item)
      self.items.push(item)
    end

    # @param [Item] this item is removed from the users item-list
    def remove_item(item)
      self.items.delete(item)
    end


    # @param [Item] checks if the user owns this item
    # @return [Boolean] True if the item is part of the users item-list
    def has_item(item)
      !(self.items.detect do |item_temp|
        item_temp.id == item.id
      end.nil?)
    end

    # @return [Array] all active items
    def items_to_sell
      items_to_sell = Array.new
      self.items.each { |item| items_to_sell.push(item) if item.active }
      items_to_sell
    end

    # @return [Array] all inactive items
    def items_not_to_sell
      items_not_to_sell = Array.new
      self.items.each { |item| items_not_to_sell.push(item) unless item.active }
      items_not_to_sell
    end

    def to_s
      "Name: #{name} Credits:#{self.credits} Items:#{self.items}"
    end

  end
end