module Marketplace

  class User

    attr_accessor :name, :credits, :items, :picture, :password, :email, :details, :verified

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
      Marketplace::Database.instance.add_user(user)
      user
    end

    # initial properties of a user
    def initialize
      self.credits = 100
      self.picture = nil
      self.details = "nothing"
      self.items = Array.new
      self.verified = false
    end

    def enough_credits(amount)
      self.credits >= amount
    end

    def change_password(password)
      self.password = BCrypt::Password.create(password)
    end

    # @param [Item] item the user want to buy
    def buy(item, quantity)
      if can_buy_item?(item, quantity)
        if quantity < item.quantity
          item_to_buy = item.split(quantity)
        else
          item_to_buy = item
        end
        seller = item_to_buy.owner
        seller.sell(item_to_buy)
        item_to_buy.owner = self
        self.remove_credits(item_to_buy.price * quantity)
        self.add_item(item_to_buy)
        item_to_buy.deactivate
      else
        throw NotImplementedError
      end
      item_to_buy
    end

    # @param [Item] item the user want to sell
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

    # @param [Item] item item is removed from users item-list
    # attention: this is not the same as deleting the item!
    def remove_item(item)
      self.items.delete(item)
    end

    # @param [Item] item item is deleted completely from the system.
    # attention: this is not the same as removing the item from the users item-list!
    def delete_item(item)
      item.delete
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
      self != item.owner and enough_credits(item.price * quantity) and item.quantity >= quantity and item.active
    end

    def delete
      #delete all its items. doesn't work without while ;)
      while !self.items.empty?
        self.items.each { |item| item.delete }
      end
      # deletes its user-pic
      if self.picture != nil
        Helper::ImageUploader.delete_image(self.picture, settings.root)
      end
      #removes self from database
      Marketplace::Database.instance.remove_user(self)
    end

    def to_s
      "Name: #{name} Credits:#{self.credits} Items:#{self.items}"
    end

    def verify
       self.verified = true
    end

    def image_path
      if self.picture == nil
        return File.join("", "images", "default_user.jpg")
      else
        return File.join("", "images", self.picture)
      end
    end

  end

end