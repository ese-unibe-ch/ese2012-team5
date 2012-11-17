module Marketplace

  class BuyOrder

    attr_accessor :item_name, :max_price, :user

    # constructor
    # @param [String] item_name of the new buy_order
    # @param [Float] max_price of the new buy_order
    # @param [User] user of the new buy_order
    # @return [Item] created buy_order
    def self.create(item_name, max_price, user)
      buy_order = self.new
      buy_order.item_name = item_name
      buy_order.max_price = max_price
      buy_order.user = user
      owner.add_item(buy_order)
      Marketplace::Database.instance.add_buy_order(buy_order)
      buy_order
    end


    def delete
      Marketplace::Database.instance.delete_buy_order(self)
    end

    def to_s
      "Item Name: #{item_name} Max Price:#{self.max_price} User:#{self.user.name}"
    end

  end

end