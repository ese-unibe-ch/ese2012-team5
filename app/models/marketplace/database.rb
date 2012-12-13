module Marketplace

  # Simple Database-like Storage Class implemented as a Singleton
  class Database

    @@instance = nil

    def initialize
      # List for all Users
      @users = []
      # List for all Items
      @items = []
      # List for all BuyOrder
      @buy_orders = []
      # List for all deactivated users
      @deactivated_users = []

      # Both hash maps use the generated hash (which is part of link) as a key
      # And map it to an array of values which holds the user [0] and the timestamp [1]
      # And map it to an array of values which holds the user [0] and the timestamp [1]
      @pw_reset = Hash.new{ |values,key| values[key] = []}
      @verification = Hash.new{ |values,key| values[key] = []}
    end

    # Gets the only instance (SINGLETON)
    def self.instance
      if(@@instance == nil)
        @@instance = Database.new
      end
      return @@instance
    end

    # Is only used for testing
    def self.reset_database
      @@instance = nil
    end


  #--------
  #BuyOrder
  #--------

    def add_buy_order(buy_order)
      @buy_orders << buy_order
    end

    def delete_buy_order(buy_order)
      @buy_orders.delete(buy_order)
    end

    def buy_order_by_id(id)
      @buy_orders.detect{ |buy_order| buy_order.id == id}
    end

    def all_buy_orders
      @buy_orders
    end

    def buy_orders_by_user(user)
      @buy_orders.select{ |buy_order| buy_order.user == user}
    end

  # Calls all buy_orders (= listeners) that the item 'item' may have changed
    def call_buy_orders(item)
      buy_orders_copy = Array.new
      @buy_orders.each{ |buy_order| buy_orders_copy << buy_order } #NOTE by urs: need to copy array, because a buy_order deletes itself directly from @buy_orders when done!
      buy_orders_copy.each{ |buy_order|
        buy_order.item_changed(item)
      }
    end


  #--------
  #Item
  #--------

    def add_item(item)
      @items << item
    end

    def delete_item(item)
      @items.delete(item)
    end

    def item_by_id(id)
      @items.detect{ |item| item.id == id}
    end

    def item_by_name(name)
      @items.select{ |item| item.name == name }
    end

    def items_by_user(user)
      @items.select{ |item| item.owner == user }
    end

    def all_items
      @items
    end

    def all_active_items
      @items.select{ |item| item.active }
    end


  #--------
  #User
  #--------

    def add_user(user)
      @users << user
    end

    def delete_user(user)
      @users.delete(user)
    end

    # @param [String] name the desired user
    # @return [User] desired user
    def user_by_name(name)
      @users.detect { |user_temp| user_temp.name == name }
    end

    # @param [String] email the desired user
    # @return [User] desired user
    def user_by_email(email)
      @users.detect { |user_temp| user_temp.email == email }
    end

    # @return [Array] all users
    def all_users
      @users
    end

    def call_users(entity)
      all_users.each{ |user|
        if user.subscriptions.include?(entity)
          user.delete_subscription(entity)
        end
      }
    end

  #--------
  #Deactivated Users
  #--------

    def add_deactivated_user(user)
      @deactivated_users << user
    end

    def deactivated_user_by_name(username)
      @deactivated_users.detect{ |user| user.name == username}
    end

    def delete_deactivated_user(user)
      @deactivated_users.delete(user)
    end


  #--------
  #Entities
  #--------

    def all_entities
      entities = Array.new
      entities << @users
      entities << @items
      entities
    end

  #--------
  #EMails
  #--------

    def all_emails
      emails = Array.new
      @users.each{ |user| emails.push(user.email)}
      emails
    end

    def email_exists?(email)
      emails = all_emails()
      emails.include?(email)
    end


  #--------
  #Password reset
  #--------

    def add_pw_reset(hash,user,timestamp)
      @pw_reset[hash][0] = user
      @pw_reset[hash][1] = timestamp
    end

    def pw_reset_user_by_hash(hash)
      @pw_reset[hash][0]
    end

    def pw_reset_timestamp_by_hash(hash)
      @pw_reset[hash][1]
    end

    def pw_reset_has?(hash)
      @pw_reset.has_key?(hash)
    end

    def delete_pw_reset(hash)
      @pw_reset.delete(hash)
    end

    # Deletes entries that are older than
    # @param [int] hours
    def clean_pw_reset_older_as(hours)
      @pw_reset.each_key {|hash|
        time_now = Time.new
        # Adds 1 day in seconds = 86400 seconds
        valid_until = pw_reset_timestamp_by_hash(hash) + hours*3600
        if time_now > valid_until
          delete_pw_reset(hash)
        end
      }
    end


    #--------
    #Verification
    #--------

    def add_verification(hash,user,timestamp)
      @verification[hash][0] = user
      @verification[hash][1] = timestamp
    end

    def verification_user_by_hash(hash)
      @verification[hash][0]
    end

    def verification_timestamp_by_hash(hash)
      @verification[hash][1]
    end

    def verification_has?(hash)
      @verification.has_key?(hash)
    end

    def delete_verification(hash)
      @verification.delete(hash)
    end

  end

end