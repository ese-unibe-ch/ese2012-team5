module Marketplace

  class Database

    @@instance = nil

    def initialize
      # list with all existing users in the whole system
      @users = []
      # list with all existing items in the whole system
      @items = []
    end

    def self.instance
      if(@@instance == nil)
        @@instance = Database.new
      end
      return @@instance
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
      categorized_items.each{ |sub_array|
        clear_category_from_user_items(sub_array,user)
        if sub_array.length == 0
          categorized_items.delete(sub_array)
        end
      }
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

  end

end