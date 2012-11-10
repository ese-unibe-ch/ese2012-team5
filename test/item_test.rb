require 'test/unit'
require 'rubygems'
require 'bcrypt'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/auction.rb'
require '../app/models/marketplace/bid.rb'
require '../app/models/marketplace/database.rb'

# syntax for inheritance
class ItemTest < Test::Unit::TestCase

  @database
  @john

  def setup
    @database = Marketplace::Database.instance
    @john = Marketplace::User.create('John','pW123','test@testmail1.com')
  end

  def test_initialization_owner
    item = Marketplace::Item.create('Table', 100,1, @john)
    assert(item.owner = @john, "Owner should be ok")
  end

  def test_initialization_price
    item = Marketplace::Item.create('Table', 100,1, @john)
    assert(item.price == 100, "Item-Price should be ok")
  end

  def test_initialization_name
    item = Marketplace::Item.create('Table', 100,1, @john)
    assert(item.name == 'Table', "Item-Name should be ok")
  end

  def test_initialization_ownerList
    item = Marketplace::Item.create('Table', 100, 1, @john)
    assert(@john.has_item?(item), "The owner should have the item in his list")
  end

  def test_initialization_inactive
    item = Marketplace::Item.create('Table', 100, 1,@john)
    assert(!item.active, "Item should be inactive after initialization")
    item.active = true
    assert(item.active)
  end

   def test_item_split
    item = Marketplace::Item.create('Table', 100, 4,@john)
    @database.add_item(item)
    item.split(1)
    assert(@database.all_items.size()==2, "There should be 2 items")

    assert_raise(ArgumentError){item.split(5)}
   end

  def test_not_in_auction_mode
    item = Marketplace::Item.create('Table', 100, 4, @john)
    assert(!item.is_in_auction_mode?)
  end

  def test_in_auction_mode
    item = Marketplace::Item.create('Table', 100, 4, @john)
    item.auction = Marketplace::Auction.create item, Time.now, 1, 1
    assert(item.is_in_auction_mode?)
  end

  def test_not_in_auction_mode_anymore
    item = Marketplace::Item.create('Table', 100, 4, @john)
    item.auction = Marketplace::Auction.create item, Time.now, 1, 1
    item.close_auction
    assert(!item.is_in_auction_mode?)
  end

  def test_can_deactivate_in_auction_mode_no_bids
    item = Marketplace::Item.create('Table', 100, 4, @john)
    item.auction = Marketplace::Auction.create item, Time.now, 1, 1
    assert(item.can_be_deactivated?)
  end

  def test_cannot_deactivate_when_bids
    item = Marketplace::Item.create('Table', 100, 4, @john)
    item.auction = Marketplace::Auction.create item, Time.now, 1, 1
    item.auction.place_bid 10, @john
    assert(!item.can_be_deactivated?)
  end


end