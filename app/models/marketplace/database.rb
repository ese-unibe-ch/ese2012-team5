module Marketplace
  class Database
    def initialize
      # list with all existing users in the whole system
      @users = []
      # list with all existing items in the whole system
      @items = []
    end
    @@instance = nil

    def self.instance
      if(@@instance == nil)
        @@instance = Database.new
      end
      return @@instance
    end

  #----Item----

    # save this item to the static item list
    def add_item(item)
      @items << item
    end

  # @param [Integer] ID of the desired item
  # @return [Item] desired item
    def item_by_id(id)
      @items.detect{|item_temp| item_temp.id == id}
    end

    # @return [Array] all items of the whole system
    def all_items
      @items
    end

    # removes this item from the item list
    def delete_item(item)
      @items.delete(item)
    end

    def items_by_user(username)
      items_by_user = Array.new
      @items.each { |item_temp| items_by_user.push(item_temp) if item_temp.owner.name == username }
      items_by_user
    end

    # lists all items in categories, except the items from the user (parameter)
    # @param [List of lists] user
    def categorized_items (user)
    end

  #User

  # @param [String] name the desired user
  # @return [User] desired user
    def user_by_name(name)
      @users.detect { |user_temp| user_temp.name == name }
    end

    # @return [Array] all users of the whole system
    def all_users
      @users
    end

    # save this user to the static user list
    def add_user(user)
      @users << user
    end

    # deletes a user account by first deleting all his items and then the user himself.
    def delete_user(user)
      user_items = items_by_user(user)
      user_items.each{|item_temp|  @items.delete(item_temp)}
      @users.delete(user)
    end

    # @return [Array] all active items
    def items_to_sell(user)
      items_to_sell = items_by_user(user)
      items_to_sell.each { |item_temp| items_to_sell.delete(item_temp) if !item_temp.active }
      items_to_sell
    end

    # @return [Array] all inactive items
    def items_not_to_sell(user)
      items_not_to_sell = items_by_user(user)
      items_not_to_sell.each { |item_temp| items_not_to_sell.delete(item_temp) if item.active }
      items_not_to_sell
    end

    # @param [Item] checks if the user owns this item
    # @return [Boolean] True if the item is part of the users item-list
    def user_has_item(user,item)
      user_items = items_by_user(user)
      !(user_items.detect do |item_temp|
        item_temp.id == item.id
      end.nil?)
    end
  end
end