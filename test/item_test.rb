require 'test/unit'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/item.rb'

# syntax for inheritance
class ItemTest < Test::Unit::TestCase

  def test_initialization_owner
    owner = Marketplace::User.create('John')
    item = Marketplace::Item.create('Table', 100, owner)
    assert(item.owner = owner, "Owner should be ok")
  end

  def test_initialization_price
    owner = Marketplace::User.create('John')
    item = Marketplace::Item.create('Table', 100, owner)
    assert(item.price == 100, "Item-Price should be ok")
  end

  def test_initialization_name
    owner = Marketplace::User.create('John')
    item = Marketplace::Item.create('Table', 100, owner)
    assert(item.name == 'Table', "Item-Name should be ok")
  end

  def test_initialization_ownerList
    owner = Marketplace::User.create('John')
    item = Marketplace::Item.create('Table', 100, owner)
    assert(owner.has_item(item), "The owner should have the item in his list")
  end

  def test_initialization_inactive
    owner = Marketplace::User.create('John')
    item = Marketplace::Item.create('Table', 100, owner)
    assert(!(item.active), "Item should be inactive after initialization")
    item.active = true
    assert(item.active)
  end

end