require 'test/unit'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'

# syntax for inheritance
class ItemTest < Test::Unit::TestCase

  def test_list
    owner = Marketplace::User.create('John')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 10, owner)
    item.activate
    assert(owner.items_to_sell.include?(item), "List should include active items" )
    item.deactivate
    assert(owner.items_not_to_sell.include?(item), "List should include inactive items" )
    assert(!owner.items_to_sell.include?(item), "List should not include inactive items" )
  end

  def test_username
    owner = Marketplace::User.create('John')
    assert(owner.name == 'John', "Username")
  end

  def test_credits
    owner = Marketplace::User.create('John')
    assert(!(owner.credits==0), "User should have some initial credits")
  end

  def test_has_bigger_amount
    user = Marketplace::User.create("Heinro")
    user.credits += 50
    assert(user.credits == 150, "credit is not 150!")
  end

  def test_has_smaller_amount
    user = Marketplace::User.create("Ulrich")
    user.credits -= 50
    assert(user.credits == 50, "credit is not 50!")
  end

  def test_initialCredits
    owner = Marketplace::User.create('John')
    assert(owner.credits==100, "User should have 100 initial credits")
  end

  def test_add_item
    # list is empty now
    owner = Marketplace::User.create("Serioso")
    assert(owner.items.length == 0, "list should be empty empty")
    itemX = Marketplace::Item.create("itemX",300,owner)
    owner.add_item(itemX)
    assert(owner.items.include?(itemX), "item was not added!")
    assert(owner.items_not_to_sell.include?(itemX), "List should include inactive items" )
    assert(!owner.items_to_sell.include?(itemX), "List should not include inactive items" )
  end

  def test_buy_item_inactive
    seller = Marketplace::User.create('John')
    buyer = Marketplace::User.create('Jack')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 10, seller)
    item.active= true
    buyer.buy(item)
    assert(!item.active, "Item should be inactive")
  end

  def test_not_enough_credits
    seller = Marketplace::User.create('John')
    buyer = Marketplace::User.create('Jack')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 101, seller)
    item.active= true
    buyer.buy(item)
    assert(seller.items.include?(item), "Item should still be on the sellers list")
    assert(buyer.credits == 100, "Credits should not change")
    assert(seller.credits == 100, "Credits should not change")
  end

  def test_not_active
    seller = Marketplace::User.create('John')
    buyer = Marketplace::User.create('Jack')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 10, seller)
    item.active= false
    buyer.buy(item)
    assert(seller.items.include?(item), "Item should still be on the sellers list")
    assert(buyer.credits == 100, "Credits should not change")
    assert(seller.credits == 100, "Credits should not change")
  end

  def test_become_owner_at_trade
    user = Marketplace::User.create("Buyer")
    owner = Marketplace::User.create("Owner")
    item = Marketplace::Item.create("someItem", 100, owner)
    item.active= true
    user.buy(item)
    assert(user.items.size == 1, "user was not able to buy!")
    assert(item.owner == user, "user is not the owner!")
  end

  def test_transfer_amount_at_trade
    user = Marketplace::User.create("Buyer")
    owner = Marketplace::User.create("Owner")
    item = Marketplace::Item.create("normalItem",100,owner)
    item.active= true
    user.buy(item)
    assert(user.credits == 0, "user has too much credit!")
    assert(owner.credits == 200, "owner has too less credit!")
  end

  def test_removes_from_user
    user = Marketplace::User.create("Buyer")
    owner = Marketplace::User.create("Owner")
    item = Marketplace::Item.create("normalItem",100,owner)
    item.active= true
    user.buy(item)
    assert(owner.items.length == 0, "owner still has the item on his list!")
  end

  def test_fail_inactive
    user = Marketplace::User.create("Buyer")
    owner = Marketplace::User.create("Owner")
    item = Marketplace::Item.create("Whoot",10,owner)
    user.buy(item)
    assert(user.items.size == 0, "user could have bought the inactive item!")
  end

end