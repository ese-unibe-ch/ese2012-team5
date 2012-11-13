require 'test/unit'
require 'rubygems'
require 'bcrypt'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/auction.rb'
require '../app/models/marketplace/bid.rb'
require '../app/models/helper/null_mailer.rb'

# syntax for inheritance
class AuctionTest < Test::Unit::TestCase

  @john
  @jim
  @item

  def setup
    @john = Marketplace::User.create('John','pW123','test@testmail1.com')
    @john.credits = 1000
    @jim = Marketplace::User.create('Jim','pW123','test@testmail1.com')
    @jim.credits = 1000
    @item = Marketplace::Item.create('Table', 100,1, @john)
    @item.activate
  end

  def test_not_over
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    assert(!auction.is_over?)
  end

  def test_is_over
    auction = Marketplace::Auction.create @item, Time.now-1, 1, 100, Helper::NullMailer
    assert(auction.is_over?)
  end

  def test_no_bids_init
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    assert(!auction.has_bids?)
  end

  def test_has_bids
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    auction.place_bid 200,@john
    assert(auction.has_bids?)
  end

  def test_no_bid_no_winning_bid
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    assert_nil(auction.current_winning_bid)
  end

  def test_one_bid_winning
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    auction.place_bid 200, @jim
    assert_equal(@jim, auction.current_winning_bid.bidder)
    assert_equal(200, auction.current_winning_bid.maximal_price)
  end

  def test_highest_bid_is_current_winning_bid
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    auction.place_bid 200, @jim
    auction.place_bid 201, @jim
    assert_equal(@jim, auction.current_winning_bid.bidder)
    assert_equal(201, auction.current_winning_bid.maximal_price)
  end

  def test_current_price_minimal_when_no_bid
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    assert_equal(100, auction.current_winning_price)
  end

  def test_cannot_bid_below_minimal
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    assert(!(auction.can_place_bid? 99))
  end

  def test_cannot_bid_same_max
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    assert(auction.can_place_bid? 200)
    auction.place_bid 200, @john
    assert(!(auction.can_place_bid? 200))
  end

  def test_get_auctions_by_user()
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    auction2 = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    auction.place_bid 200, @jim
    assert_equal(Marketplace::Auction.get_auctions_by_user(@jim)[0], auction)
    assert_equal(Marketplace::Auction.get_auctions_by_user(@jim)[1], nil)
    auction.place_bid 300, @john
    assert_equal(Marketplace::Auction.get_auctions_by_user(@jim)[0], nil)
    auction.place_bid 400, @jim
    auction2.place_bid 100, @jim
    assert_equal(Marketplace::Auction.get_auctions_by_user(@jim)[0], auction)
    assert_equal(Marketplace::Auction.get_auctions_by_user(@jim)[1], auction2)
    assert_equal(Marketplace::Auction.get_auctions_by_user(@jim)[2], nil)
    assert_equal(@jim.frozen_credits, 500)
  end

  def test_current_price_and_winner_inc1
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100, Helper::NullMailer
    assert_equal(100, auction.current_winning_price)

    auction.place_bid 101, @jim
    assert_equal(100, auction.current_winning_price)
    assert_equal(@jim, auction.current_winner)

    auction.place_bid 102, @john
    assert_equal(102, auction.current_winning_price)
    assert_equal(@john, auction.current_winner)

    auction.place_bid 110, @jim
    assert_equal(103, auction.current_winning_price)
    assert_equal(@jim, auction.current_winner)

    auction.place_bid 105, @john
    assert_equal(106, auction.current_winning_price)
    assert_equal(@jim, auction.current_winner)

    auction.place_bid 120, @john
    assert_equal(111, auction.current_winning_price)
    assert_equal(@john, auction.current_winner)
  end

  def test_current_price_and_winner_inc10
    auction = Marketplace::Auction.create @item, Time.now+1, 10, 100, Helper::NullMailer
    assert_equal(100, auction.current_winning_price)

    auction.place_bid 150, @jim
    assert_equal(100, auction.current_winning_price)
    assert_equal(@jim, auction.current_winner)

    auction.place_bid 120, @john
    assert_equal(130, auction.current_winning_price)
    assert_equal(@jim, auction.current_winner)

    auction.place_bid 170, @john
    assert_equal(160, auction.current_winning_price)
    assert_equal(@john, auction.current_winner)

    auction.place_bid 200, @john
    assert_equal(160, auction.current_winning_price)
    assert_equal(@john, auction.current_winner)

    auction.place_bid 220, @jim
    assert_equal(210, auction.current_winning_price)
    assert_equal(@jim, auction.current_winner)
  end

  def test_item_goes_to_jim_one_bid
    auction = Marketplace::Auction.create @item, Time.now+10, 10, 100, Helper::NullMailer
    auction.place_bid 200, @jim
    auction.end_time=Time.now-1
    auction.update
    assert_equal(100, @item.price)
    assert_equal(@jim, @item.owner)
    assert_equal(900, @jim.credits)
  end

  def test_item_goes_to_jim_more_bids
    auction = Marketplace::Auction.create @item, Time.now+10, 10, 100, Helper::NullMailer
    auction.place_bid 200, @jim
    auction.place_bid 300, @john
    auction.place_bid 400, @jim
    auction.end_time=Time.now-1
    auction.update
    assert_equal(310, @item.price)
    assert_equal(@jim, @item.owner)
    assert_equal(1310, @john.credits)
  end


end