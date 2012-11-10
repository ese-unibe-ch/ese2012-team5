require 'test/unit'
require 'rubygems'
require 'bcrypt'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/auction.rb'
require '../app/models/marketplace/bid.rb'
require '../app/models/marketplace/database.rb'

# syntax for inheritance
class AuctionTest < Test::Unit::TestCase

  @database
  @john
  @jim
  @item

  def setup
    @database = Marketplace::Database.instance
    @john = Marketplace::User.create('John','pW123','test@testmail1.com')
    @jim = Marketplace::User.create('Jim','pW123','test@testmail1.com')
    @item = Marketplace::Item.create('Table', 100,1, @john)
  end

  def test_not_over
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    assert(!auction.is_over?)
  end

  def test_is_over
    auction = Marketplace::Auction.create @item, Time.now-1, 1, 100
    assert(auction.is_over?)
  end

  def test_no_bids_init
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    assert(!auction.has_bids?)
  end

  def test_has_bids
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    auction.place_bid 200,@john
    assert(auction.has_bids?)
  end

  def test_no_bid_no_winning_bid
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    assert_nil(auction.current_winning_bid)
  end

  def test_one_bid_winning
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    auction.place_bid 200, @jim
    assert_equal(@jim, auction.current_winning_bid.bidder)
    assert_equal(200, auction.current_winning_bid.maximal_price)
  end

  def test_highest_bid_is_current_winning_bid
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    auction.place_bid 200, @jim
    auction.place_bid 201, @jim
    assert_equal(@jim, auction.current_winning_bid.bidder)
    assert_equal(201, auction.current_winning_bid.maximal_price)
  end

  def test_current_price_minimal_when_no_bid
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    assert_equal(100, auction.current_winning_price)
  end

  def test_cannot_bid_below_minimal
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    assert(!(auction.can_place_bid? 99))
  end

  def test_cannot_bid_same_max
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
    assert(auction.can_place_bid? 200)
    auction.place_bid 200, @john
    assert(!(auction.can_place_bid? 200))
  end

  def test_current_price_and_winner_inc1
    auction = Marketplace::Auction.create @item, Time.now+1, 1, 100
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
    auction = Marketplace::Auction.create @item, Time.now+1, 10, 100
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


end