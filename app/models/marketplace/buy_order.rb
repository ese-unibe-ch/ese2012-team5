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
    def compare(item)
      if matches?(item)
        if item.active
          puts "buy order #{self} was successful with item: #{item}"
          user.buy(item, 1)
        else
          puts "bad luck. someone else was faster with buy order #{self} and item: #{item}"
        end
      else
        puts "buy order #{self} was NOT successful! with item: #{item}"
      end
    end

    def matches?(item)
      item.name == item_name and item.price < max_price
    end

    def to_s
      "Item Name: #{item_name} Max Price:#{self.max_price} User:#{self.user.name}"
    end

  end

end