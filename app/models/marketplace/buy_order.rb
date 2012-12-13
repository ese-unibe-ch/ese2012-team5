module Marketplace

  #todo:fix bug with too expensive buy orders

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

    # Initial property of an item
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
      if item.name == self.item_name and item.price <= self.max_price
        if item.active
          if self.user.can_buy_item?(item, self.quantity)
            bought_item = self.user.buy(item, self.quantity)
            self.delete
          end
        end # @note by urs: not all ifs in one for better overview
      end
    end

    def to_s
      "Item Name: #{item_name} Max Price:#{self.max_price} User:#{self.user.name}"
    end

    def delete
      Marketplace::Database.instance.delete_buy_order(self)
    end

  end

end