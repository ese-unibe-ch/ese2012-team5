module Marketplace

#TODO switch to full database use and remove redundancy between user and item and always get relational information's with database!

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

       #TODO fix imageUpload, at editItem, userSettings, and add to createItem
      # Counter for uploaded images
      @imageCount = 0


      #TODO rename that stuff into more intuitive names
      # These are two hashmaps with the generated hash (link) as a key
      # mapped to an array of values which holds the user [0] and the timestamp [1]
      @reset_pw_hashmap = Hash.new{ |values,key| values[key] = []}
      @verification_hashmap = Hash.new{ |values,key| values[key] = []}
    end

    # Gets the only instance (SINGLETON)
    def self.instance
      if(@@instance == nil)
        @@instance = Database.new
      end
      return @@instance
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

  # Calls all buy_order.item_changed with changed item
  def call_buy_orders(item)
    puts "start with all buy_orders"
    @buy_orders.each{ |buy_order| buy_order.item_changed(item) }
    puts "done with all buy_orders"
  end


  #--------
  #Item
  #--------

    def add_item(item)
      @items << item
    end

    def delete_item(item)
      item.delete
      @items.delete(item)
    end

    # @param [Integer] id of the desired item
    # @return [Item]  item with desired id
    def item_by_id(id)
      @items.detect{ |item| item.id == id}
    end

    def item_by_name(name)
      @items.select{ |item| item.name == name }
    end

    # @return [Array] all items
    def all_items
      @items
    end

    # @return [Array] all active items
    def all_active_items
      @items.select{ |item| item.active }
    end


    #--------
    #Item Category
    #--------

    # Categories all ACTIVE items by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def categories_items
      all_items = self.all_active_items
      categorized_items = Array.new

      all_items.each{ |item|
        sub_array = categorized_items.detect{ |sub_item_array| sub_item_array[0].name == item.name }
        if sub_array != nil
          sub_array.push(item)
        else
          new_sub_array = Array.new
          new_sub_array.push(item)
          categorized_items.push(new_sub_array)
        end
      }
      categorized_items
    end

    # Categories all ACTIVE items without items of user by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def categories_items_without(user)
      categorized_items = categories_items

      categorized_items.each{ |sub_array| clear_category_from_user_items(sub_array,user) }
      categorized_items.each{ |sub_array|
        if sub_array.length == 0 or sub_array == nil
          categorized_items.delete(sub_array)
        end
      } # NOTE by Urs: don't do both in one .each! -> bug
      categorized_items
    end

    # Removes all items of desired user from category
    def clear_category_from_user_items(category, user)
      category.delete_if{ |item| item.owner == user }
    end

    # Selects the category with desired name
    def category_with_name(name)
      categorized_items = categories_items
      categorized_items.detect{ |sub_item_array| sub_item_array[0].name == name }
    end

    # Sorts a categorized_item list by the price
    # @return [Array of Arrays] sorted array with arrays for every different item.name
    def sort_categories_by_price(categorized_items)
      sorted_categories = Array.new
      categorized_items.each{ |sub_array|
        if sub_array.size > 1
          sorted_categories.push(sort_category_by_price(sub_array))
        else
          sorted_categories.push(sub_array)
        end
     }
      sorted_categories
    end

    # Sorts a category by the price
    def sort_category_by_price(category)
      category.sort! {|a,b| a.price <=> b.price}
    end


  #--------
  #User
  #--------

    def add_user(user)
      @users << user
    end

    # Deletes the user and all his items
    def delete_user(user)
      user.delete
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

  #TODO use nicer variable names
  #--------
  #Methods for Pw-Reset and Verification Mail hashs
  #--------

    #Methods for the @reset_pw_hashmap

    def add_to_rp_hashmap(hash,user,timestamp)
      @reset_pw_hashmap[hash][0] = user
      @reset_pw_hashmap[hash][1] = timestamp
    end

    def get_user_from_rp_hashmap_by(hash)
      @reset_pw_hashmap[hash][0]
    end

    def get_timestamp_from_rp_hashmap_by(hash)
      @reset_pw_hashmap[hash][1]
    end

    def hash_exists_in_rp_hashmap?(hash)
      @reset_pw_hashmap.has_key?(hash)
    end

    def delete_from_rp_hashmap(hash)
      @reset_pw_hashmap.delete(hash)
    end

    #deletes entries that are older than
    # @param [int] hours
    def delete_old_entries_from_rp_hashmap(hours)
      @reset_pw_hashmap.each_key {|hash|
        time_now = Time.new
        # adds 1 day in seconds = 86400 seconds
        valid_until = get_timestamp_from_rp_hashmap_by(hash) + hours*3600
        if time_now > valid_until
          delete_from_rp_hashmap(hash)
        end
      }
    end

    #Methods for the @verification_hashmap

    def add_to_ver_hashmap(hash,user,timestamp)
      @verification_hashmap[hash][0] = user
      @verification_hashmap[hash][1] = timestamp
    end

    def get_user_from_ver_hashmap_by(hash)
      @verification_hashmap[hash][0]
    end

    def get_timestamp_from_ver_hashmap_by(hash)
      @verification_hashmap[hash][1]
    end

    def hash_exists_in_ver_hashmap?(hash)
      @verification_hashmap.has_key?(hash)
    end

    def delete_entry_from_ver_hashmap(hash)
      @verification_hashmap.delete(hash)
    end

  end

end