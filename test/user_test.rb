require 'test/unit'
require 'rubygems'
require 'bcrypt'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/database.rb'

# syntax for inheritance
class UserTest < Test::Unit::TestCase

  def test_list
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 10, 12, owner)
    item.activate
    assert(owner.items.include?(item), "List should include active items" )
  end

  def test_username
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    assert(owner.name == 'John', "Username")
  end

  def test_credits
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    assert(!(owner.credits==0), "User should have some initial credits")
  end

  def test_has_bigger_amount
    database = Marketplace::Database.instance
    user = Marketplace::User.create("Heinro",'pW123','test@testmail1.com')
    user.credits += 50
    assert(user.credits == 150, "credit is not 150!")
  end

  def test_has_smaller_amount
    database = Marketplace::Database.instance
    user = Marketplace::User.create("Ulrich",'pW123','test@testmail1.com')
    user.credits -= 50
    assert(user.credits == 50, "credit is not 50!")
  end

  def test_initialCredits
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    assert(owner.credits==100, "User should have 100 initial credits")
  end

  def test_add_item
    database = Marketplace::Database.instance
    # list is empty now
    owner = Marketplace::User.create("Serioso","pW123",'test@testmail1.com')
    assert(owner.items.length == 0, "list should be empty empty")
    itemX = Marketplace::Item.create("itemX",300,21,owner)
    owner.add_item(itemX)
    assert(owner.items.include?(itemX), "item was not added!")
  end

  def test_buy_item_inactive
    database = Marketplace::Database.instance
    seller = Marketplace::User.create('John','pW123','test@testmail1.com')
    buyer = Marketplace::User.create('Jack','pW123','test@testmail1.com')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 10,1, seller)
    item.active= true
    buyer.buy(item)
    assert(!item.active, "Item should be inactive")
  end

  def test_not_enough_credits
    database = Marketplace::Database.instance
    seller = Marketplace::User.create('John','pW123','test@testmail1.com')
    buyer = Marketplace::User.create('Jack','pW123','test@testmail1.com')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 101, 1,seller)
    item.active= true
    assert_raise(NameError){user.buy(item)}
    assert(seller.items.include?(item), "Item should still be on the sellers list")
    assert(buyer.credits == 100, "Credits should not change")
    assert(seller.credits == 100, "Credits should not change")
  end

  def test_not_active
    database = Marketplace::Database.instance
    seller = Marketplace::User.create('John','pW123','test@testmail1.com')
    buyer = Marketplace::User.create('Jack','pW123','test@testmail1.com')
    item = Marketplace::Item.create('The Lord of The Rings, Books', 10,1, seller)
    item.active= false
    assert_raise(NameError){user.buy(item)}
    assert(seller.items.include?(item), "Item should still be on the sellers list")
    assert(buyer.credits == 100, "Credits should not change")
    assert(seller.credits == 100, "Credits should not change")
  end

  def test_become_owner_at_trade
    database = Marketplace::Database.instance
    user = Marketplace::User.create("Buyer",'pW123','test@testmail1.com')
    owner = Marketplace::User.create("Owner",'pW123','test@testmail1.com')
    item = Marketplace::Item.create("someItem", 100,1, owner)
    item.active= true
    user.buy(item)
    assert(user.items.size == 1, "user was not able to buy!")
    assert(item.owner == user, "user is not the owner!")
  end

  def test_transfer_amount_at_trade
    database = Marketplace::Database.instance
    user = Marketplace::User.create("Buyer",'pW123','test@testmail1.com')
    owner = Marketplace::User.create("Owner",'pW123','test@testmail1.com')
    item = Marketplace::Item.create("normalItem",100,1,owner)
    item.active= true
    user.buy(item)
    assert(user.credits == 0, "user has too much credit!")
    assert(owner.credits == 200, "owner has too less credit!")
  end

  def test_removes_from_user
    database = Marketplace::Database.instance
    user = Marketplace::User.create("Buyer",'pW123','test@testmail1.com')
    owner = Marketplace::User.create("Owner",'pW123','test@testmail1.com')
    item = Marketplace::Item.create("normalItem",100,1,owner)
    item.active= true
    user.buy(item)
    assert(owner.items.length == 0, "owner still has the item on his list!")
  end

  def test_fail_inactive
    database = Marketplace::Database.instance
    user = Marketplace::User.create("Buyer",'pW123','test@testmail1.com')
    owner = Marketplace::User.create("Owner",'pW123','test@testmail1.com')
    item = Marketplace::Item.create("Whoot",10,1,owner)
    assert_raise(TypeError){user.buy(item)}
  end

end