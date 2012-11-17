module Marketplace

  class BuyOrder

    attr_accessor :item_name, :max_price, :user

    def self.create(item_name, max_price, user)
      buy_order = self.new
      buy_order.item_name = item_name
      buy_order.max_price = max_price
      buy_order.user = user
      Marketplace::Database.instance.add_buy_order(buy_order)
      buy_order
      #TODO is the buy_order is already possible to solve, we shouldn't even create one!
    end

    # Called every time a item changes
    # First buy_order that is able to buy the item will get it ;)
    def item_changed(item)
      if item.name == item_name and item.price < max_price
        if item.active
          #TODO Buy item
          puts "buy order #{self} was successful! with item: #{item}"
          item.deactivate
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