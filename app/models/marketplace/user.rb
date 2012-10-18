module Marketplace
  class User

    attr_accessor :name, :credits, :items, :picture, :password, :email, :details

    # constructor with password
    # @param [String] name of the new user
    # @param [String] password of the new user
    # @return [Item] created item
    def self.create(name, password)
      user = self.new
      user.name = name
      user.password = BCrypt::Password.create(password)
      user
    end

    # initial properties of a user
    def initialize
      self.credits = 100
      self.picture = "default_profile.jpg"
      self.details = "nothing"
      self.items = Array.new
    end

    def enough_credits(amount)
      self.credits >= amount
    end

    # @param [Item] item the user want to buy
    def buy(item)
      if self.enough_credits(item.price * item.quantity) && item.active
        item.owner.sell(item)
        item.owner = self
        self.remove_credits(item.price * item.quantity)
        item.deactivate
      end
    end

    # @param [Item] item the user want to sell
    def sell(item)
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

    def to_s
      "Name: #{name} Credits:#{self.credits} Items:#{self.items}"
    end
  end
end