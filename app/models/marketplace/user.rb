module Marketplace

  # Users are created when someone registers. A user needs a name and password to login and an email address to verify himself.
  # A user has a profile page where he can put his details and a picture. The details, the picture and the password can be changed.
  # A user can create and sell/buy items to other users in exchange for credits.
  # A user can also subscribe to other users and items and view their activities in the activity log.
  class User < Entity

    attr_accessor :name, :credits, :picture, :password, :email, :details, :verified , :subscriptions

    # Constructor that will automatic add new user to database
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
      Marketplace::Activity.create(Activity.USER_CREATED, user, "#{user.name} has been created")
      user
    end

    # Initial properties of a user
    def initialize
      super
      self.credits = 100
      self.picture = nil
      self.details = "No description"
      self.verified = false
      self.subscriptions = Array.new
    end

    # @param [Integer] amount of credits that user must have to perform action
    # @return [Boolean] true if user has at least amount of credits
    def has_enough_credits?(amount)
      self.credits >= amount
    end

    # @param [String] password that will be set
    def change_password(password)
      self.password = BCrypt::Password.create(password)
    end

    # Buy method that covers the whole buy process
    # @param [Item] item the user want to buy
    # @param [Integer] quantity of the item to buy
    # @return [Item] item that has been bought with 'quantity'
    # raise [NotImplementedError] when user can't do this purchase
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
        item_to_buy.deactivate
        Marketplace::Activity.create(Activity.ITEM_BOUGHT, item, "#{item.name} has been bought by #{self.name}")
        Marketplace::Activity.create(Activity.USER_BOUGHT_ITEM, self, "#{self.name} bought #{item.name}")
        #delete the history in the description log, except the newest entry
        item_to_buy.clean_description_log
        item_to_buy.clean_comments
      else
        raise ArgumentError
      end
      item_to_buy
    end

    # Will be called through Method buy(item,quantity)
    # @param [Item] item the user want to sell
    def sell(item)
      self.add_credits(item.price * item.quantity)
      Marketplace::Activity.create(Activity.ITEM_SOLD, item, "#{item.name} has been sold by #{self.name}")
      Marketplace::Activity.create(Activity.USER_SOLD_ITEM, self, "#{self.name} sold #{item.name}")
    end

    # @param [Integer] amount of credits to add to user's total
    def add_credits(amount)
      self.credits += amount
    end

    # @param [Integer] amount of credits to remove from user's total
    def remove_credits(amount)
      self.credits -= amount
    end

    # @param [Item] item to check if the user owns it
    # @return [Boolean] true if user owns it
    def has_item?(item)
      items = Marketplace::Database.instance.items_by_user(self)
      items.include?(item)
    end

    # @return [List of Item] all items of user
    def items
      Marketplace::Database.instance.items_by_user(self)
    end

    # @param [Item] item item to buy
    # @param [Integer] quantity how much of the item
    # @return [Boolean] True if user has enough credits, is not owner and item is active
    def can_buy_item?(item, quantity)
      self != item.owner and has_enough_credits?(item.price * quantity) and item.quantity >= quantity and item.active
    end

    # Deletes the user, its profile picture and all its items
    def delete
      Marketplace::Database.instance.call_users(self)
      Marketplace::Database.instance.delete_user(self)
      ImageUploader.delete_image(self.picture, settings.root) if self.picture != nil
      items = Marketplace::Database.instance.items_by_user(self)
      items.each{ |item| item.delete }
    end

    # Deactivates the user
    # Therefore it deactivates all items, deletes all buy_orders and
    # swaps user to deactivated_users list
    def deactivate
      items = Marketplace::Database.instance.items_by_user(self)
      items.each{ |item| item.deactivate }

      buy_orders = Marketplace::Database.instance.buy_orders_by_user(self)
      buy_orders.each{ |buy_order| buy_order.delete }

      Marketplace::Database.instance.add_deactivated_user(self)
      Marketplace::Database.instance.delete_user(self)
      Marketplace::Activity.create(Activity.USER_DEACTIVATE, self, "#{self.name} has been deactivated")
    end

    # Activates the user
    # Therefore re-adds user to database
    def activate
      Marketplace::Database.instance.delete_deactivated_user(self)
      Marketplace::Database.instance.add_user(self)
      Marketplace::Activity.create(Activity.USER_REACTIVATE, self, "#{self.name} has been reactivated")
    end

    # To String method of User object.
    # @return [String] data of User object
    def to_s
      "Name: #{name} Credits:#{self.credits} ItemsCount:#{self.items.length}"
    end

    # Sets the verification status of User to verified
    def verify
       self.verified = true
    end

    # @return [String] path of user profile picture
    def image_path
      if self.picture == nil
        return File.join("", "images", "default_user.jpg")
      else
        return File.join("", "images", self.picture)
      end
    end

    # Adds entity to User's subscription list
    # @param [Entity] to add
    def add_subscription(entity)
      subscriptions << entity
    end

    # Removes entity from User's subscription list
    # @param [Entity] to remove
    def delete_subscription(entity)
      subscriptions.delete(entity)
    end

    # @param [Entity] to check
    # @return [Boolean] true if User follows entity
    def follows?(entity)
      subscriptions.include?(entity)
    end

  end

end