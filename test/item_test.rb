require 'test/unit'
require 'rubygems'
require 'bcrypt'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/database.rb'

# syntax for inheritance
class ItemTest < Test::Unit::TestCase

  def test_initialization_owner
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    item = Marketplace::Item.create('Table', 'No Description', 100,1, owner)
    assert(item.owner = owner, "Owner should be ok")
  end

  def test_initialization_price
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    item = Marketplace::Item.create('Table', 'No Description', 100,1, owner)
    assert(item.price == 100, "Item-Price should be ok")
  end

  def test_initialization_name
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    item = Marketplace::Item.create('Table', 'No Description', 100,1, owner)
    assert(item.name == 'Table', "Item-Name should be ok")
  end

  def test_initialization_ownerList
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    item = Marketplace::Item.create('Table', 'No Description', 100, 1, owner)
    assert(owner.has_item?(item), "The owner should have the item in his list")
  end

  def test_initialization_inactive
    database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    item = Marketplace::Item.create('Table', 'No Description', 100, 1,owner)
    assert(!(item.active), "Item should be inactive after initialization")
    item.active = true
    assert(item.active)
  end

   def test_item_split
    @database = Marketplace::Database.instance
    owner = Marketplace::User.create('John','pW123','test@testmail1.com')
    item = Marketplace::Item.create('Table', 'No Description', 100, 4,owner)
    Marketplace::Database.instance.add_item(item)
    item.split(1)
    assert(@database.all_items.size()==2, "There should be 2 items")

    assert_raise(TypeError){item.split(5)}

  end

end