module Marketplace
  class Auction
    attr_accessor :item, :end_time, :bids, :increment, :minimal_price, :notifier
    @@auctions = []

    @@auction_success_mail = <<EOF
Hi %s

you just successfully won item:
%s
for %d credits.

Regards,
Your item|market - Team
EOF

    @@outbid_mail = <<EOF
Hi %s

you have been outbid on item:
%s
Current price is: %d

Regards,
Your item|market - Team
EOF

    def self.create(item, end_time, incr, minimal_price, notifier)
      a = self.new
      a.item = item
      a.end_time = end_time
      a.increment = incr
      a.minimal_price = minimal_price
      a.notifier = notifier
      a.item.auction = a
      @@auctions << a
      a
    end

    def initialize
      self.bids = []
    end

    def is_over?
      self.end_time <= Time.now
    end

    def has_bids?
      self.bids.length > 0
    end

    def update
      return unless self.is_over?

      if !self.has_bids?
        self.item.deactivate # If there was no bidder (n=0), the auction simply closes.
        return
      end

      # sell if there's a bidder
      # At the time the auction terminates and there was at least one bidder (n>0), the transaction proceeds in
      # accordance with the current winner and the current selling price at that time.
      # The winner receives a confirmation email.
      wnr = self.current_winner
      self.item.price = self.current_winning_price
      self.item.close_auction
      wnr.buy(self.item)

      # send confirmation email to winner
      msg = sprintf(@@auction_success_mail, wnr.name, self.item.name, self.current_winning_price)
      self.notifier.send(msg, wnr.email)
    end

    # nil if there's none
    def current_winner
      return nil if !self.has_bids?
      return current_winning_bid.bidder
    end

    def current_winning_bid
      return nil if self.bids.length == 0
      return self.bids.last
    end

    # must be in auction mode
    def current_winning_price
      if self.bids.length <= 1 # sell for initial price if there's only one bidder
        return self.minimal_price
      else
        # the current selling price is defined as MP(n-1)+increment.
        return self.bids.last(2)[0].maximal_price + self.increment
      end
    end

    # The maximal price of the bid must be >= the minimal price defined in the auction.
    # two bidders cannot have the same maximal price AND
    # a bid cannot be between self.get_auction_current_winning_bid.maximal_price +- self.increment
    # because this would cause the current selling price to become a value that neither the current winner nor the new bidder is ready to pay
    def can_place_bid?(maximal_price)
      return false if maximal_price < self.minimal_price
      return true if !self.has_bids?

      same_price_bid = self.bids.detect{ |b| b.maximal_price == maximal_price}
      return false if same_price_bid != nil

      return false if maximal_price < self.current_winning_bid.maximal_price + self.increment &&
          maximal_price > self.current_winning_bid.maximal_price - self.increment

      return true
    end

    # returns false if the bid could not be placed because it was not an increase
    def place_bid(maximal_price, bidder)
      raise "cannot place that bid" unless self.can_place_bid?(maximal_price)
      raise "cannot bid #{maximal_price}, you only have #{bidder.credits}" unless bidder.enough_credits(maximal_price)

      if self.has_bids? && self.current_winning_bid.bidder == bidder
        # just increase old max value if bigger than it
        if maximal_price < self.current_winning_bid.maximal_price
          return false
        end
        self.current_winning_bid.maximal_price = maximal_price
      else
        # create new
        bid = Bid.new
        bid.bidder = bidder
        bid.maximal_price = maximal_price

        if self.current_winner
          # send the notification mail to the old winner (self.get_auction_current_winner)
          # since we have a new (if it were the same, we would be in the "if", not the "else" branch)
          msg = sprintf(@@outbid_mail, self.current_winner.name, self.item.name, (self.current_winning_price + self.increment))
          self.notifier.send(msg, self.current_winner.email)
        end

        self.bids << bid
        self.bids = order_bids_ascending

      end
      return true
    end

    #returns all auctions on which a specific user is currently holding the highest bid
    def self.get_auctions_by_user(user)
        return @@auctions.select{ |auction| auction.current_winner == user}
    end


    private

    def order_bids_ascending
      # http://ariejan.net/2007/01/28/ruby-sort-an-array-of-objects-by-an-attribute
      return self.bids.sort { |a,b| a.maximal_price <=> b.maximal_price }
    end

  end
end