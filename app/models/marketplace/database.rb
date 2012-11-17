module Marketplace

#TODO switch to full database use and remove redundancy between user and item and always get relational information's with database!

  class Database

    @@instance = nil

    def initialize
      # list with all existing users in the whole system
      @users = []
      # list with all existing items in the whole system
      @items = []

      # These are two hashmaps with the generated hash (link) as a key
      # mapped to an array of values which holds the user [0] and the timestamp [1]
      @reset_pw_hashmap = Hash.new{ |values,key| values[key] = []}
      @verification_hashmap = Hash.new{ |values,key| values[key] = []}

      # List for all BuyOrder
      @buy_orders = []

    end

    def self.instance
      if(@@instance == nil)
        @@instance = Database.new
      end
      return @@instance
    end


  #--------
  #BuyOrder
  #--------

  # Adds a new buyOrder to the database
  def add_buy_order(buy_order)
    @buy_orders << buy_order
  end

  def buy_orders
    @buy_orders
  end

  def buy_orders_by_user(user)
    @buy_orders.select{ |buy_order| buy_order.user == user}
  end

  # Calls all buy_order.item_changed with changed item
  def fire_item_changed(item)
    @buy_orders.each{ |buy_order| buy_order.item_changed(item) }
  end

  #--------
  #Item
  #--------

    # save this item to the static item list
    def add_item(item)
      @items << item
    end

    # @param [Integer] id of the desired item
    # @return [Item] desired item
    def item_by_id(id)
      @items.detect{ |item| item.id == id}
    end

    # @return [Array] all items of the whole system
    def all_items
      @items
    end

    # @return [Array] all active items of the whole system
    def all_active_items
      @items.select{ |item| item.active }
    end

    # removes this item from the item list
    def delete_item(item)
      item.delete
      @items.delete(item)
    end


    #--------
    #Item Category
    #--------

    # categories all ACTIVE items by their name
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

    # categories all ACTIVE items without items of user by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def categories_items_without(user)
      categorized_items = categories_items
      categorized_items.each{ |sub_array| clear_category_from_user_items(sub_array,user) }
      categorized_items.each{ |sub_array|
        if sub_array.length == 0 or sub_array == nil
          categorized_items.delete(sub_array)
        end
      } # note by Urs: don't do both in one .each! -> bug
      puts categorized_items
      categorized_items
    end

    def clear_category_from_user_items(category, user)
      category.delete_if{ |item| item.owner == user }
    end

    def category_with_name(name)
      categorized_items = categories_items
      categorized_items.detect{ |sub_item_array| sub_item_array[0].name == name }
    end

    # sorts a categorized_item list by the price
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

    def sort_category_by_price(category)
      category.sort! {|a,b| a.price <=> b.price}
    end


  #--------
  #User
  #--------

    # save this user to the static user list
    def add_user(user)
      @users << user
    end

    # @param [String] name the desired user
    # @return [User] desired user
    def user_by_name(name)
      @users.detect { |user_temp| user_temp.name == name }
    end

    def user_by_email(email)
      @users.detect { |user_temp| user_temp.email == email }
    end

    # @return [Array] all users of the whole system
    def all_users
      @users
    end

    # deletes a user account by first deleting all his items and then the user himself.
    def delete_user(user)
      user.items.each{ |item| delete_item(item)}
      user.delete
      @users.delete(user)
    end

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