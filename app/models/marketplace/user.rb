module Marketplace
  class User

    # every user has a different name
    #

    @@users = Array.new

    attr_accessor :name, :credits, :items, :picture, :password


    def create(name)
    end

    def initialize
    end

    def self.by_name(name)
    end

    def self.all
      @@users
    end

    def save
      @@users.push(self)
    end

    def enough_credits(amount)
    end

    def buy(item)
    end

    def add_credits(amount)
    end

    def remove_credits(amount)
    end

    def add_item(item)
    end

    def remove_item(item)
    end

    def has_item(item)
    end

    def items_to_sell()
    end

    def items_not_to_sell()
    end

    def to_s
      "Name: #{name} Credits:#{self.credits} Items:#{self.list_items}"
    end

  end
end