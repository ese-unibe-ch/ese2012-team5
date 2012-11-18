module Marketplace

  class BuyOrder

    # static variables: id for a unique identification
    @@id = 1

    attr_accessor :id, :item_name, :max_price, :quantity, :user

    # constructor
    # quantity is always 1
    # @param [String] item_name of the wanted item
    # @param [Float] max_price of the wanted item
    # @param [User] user of the buy_order
    # @return [BuyOrder] created buy_order
    def self.create(item_name, max_price, user)
      buy_order = self.new
      buy_order.id = @@id
      @@id += 1
      buy_order.item_name = item_name
      buy_order.max_price = max_price
      buy_order.quantity = 1 #NOTE hardcoded quantity
      buy_order.user = user
      Marketplace::Database.instance.add_buy_order(buy_order)
      buy_order
    end

    # Called every time a item changes
    # First buy_order that is able to buy the item will get it ;)
    # To be able to buy the item, the user must have enough credits,
    # the item must have the same name and its price must be lower
    # than max_price
    def item_changed(item)
      if item.name == self.item_name and item.price < self.max_price
        if item.active

          if self.user.can_buy_item?(item, self.quantity)
            bought_item = self.user.buy(item, self.quantity)
            puts "buy order #{self} was successful! with item: #{item}"
            puts "bought item #{bought_item}"
            Marketplace::Database.instance.delete_buy_order(self)
          end

        else
          #TODO Seems as another buy_order was faster ;) DO NOTHING??
          puts "buy order #{self} was too late! with item: #{item}"
        end
      else
        puts "buy order #{self} was NOT successful! with item: #{item}"
      end
    end

    def to_s
      "Item Name: #{item_name} Max Price:#{self.max_price} User:#{self.user.name}"
    end

  end

end