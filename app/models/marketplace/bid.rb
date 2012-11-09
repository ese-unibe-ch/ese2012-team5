module Marketplace
  class Bid
    attr_accessor :bidder, # a User,
                  :maximal_price # a real value
  end
end