module Marketplace

  # Buy orders can be created by users that want to define a specific item for a specific price they would like to buy.
  # Every time an item gets activated every buy order gets checked if the item is of any use for it.
  class BuyOrder

    # Static variable
    # ID for a unique identification of each buy_order
    @@id = 1

    attr_accessor :id, :item_name, :max_price, :quantity, :user

    # Constructor that will automatic add new buy_order to database
    # @note by urs: quantity is at moment always 1
    # @param [String] item_name of the wanted item
    # @param [Float] max_price of the wanted item
    # @param [User] user of the buy_order
    # @return [BuyOrder] created buy_order
    def self.create(item_name, max_price, user)
      buy_order = self.new
      buy_order.item_name = item_name
      buy_order.max_price = max_price
      buy_order.user = user
      Marketplace::Database.instance.add_buy_order(buy_order)
      buy_order
    end

    # Initial property of a buy_order
    def initialize
      self.id = @@id
      @@id += 1
      self.quantity = 1
    end

    # Called every time a item changes
    # First buy_order that is able to buy the item will get it ;)
    # To be able to buy the item, the user must have enough credits,
    # the item must have the same name and its price must be lower
    # than max_price
    def item_changed(item)
      return unless item.name == self.item_name and item.price.to_i <= self.max_price.to_i
      return unless item.active
      return unless self.user.can_buy_item?(item, self.quantity)
      begin
        self.user.buy(item, self.quantity)
        self.delete
      rescue ArgumentError
      end
    end

    # To String method of buy_order.
    # @return [String] Data of buy_order object in String format.
    def to_s
      "Item Name: #{item_name} Max Price:#{self.max_price} User:#{self.user.name}"
    end


    def delete
      Marketplace::Database.instance.delete_buy_order(self)
    end

  end

end