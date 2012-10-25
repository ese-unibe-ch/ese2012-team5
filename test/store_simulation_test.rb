require 'test/unit'
require 'rubygems'
require 'bcrypt'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/database.rb'

class StoreSimulationTest < Test::Unit::TestCase

  def test_simu
    database = Marketplace::Database.instance
    john = Marketplace::User.create('John','pW123','test@testmail1.com')
    jack = Marketplace::User.create('Jack','pW123','test@testmail1.com')
    item1 = Marketplace::Item.create('Gartentisch XL', 50,1, john)
    item1.active=true
    item2 = Marketplace::Item.create('DVD', 10,1, jack)
    puts("Gartentisch Item: #{item1}")
    puts("DVD Item: #{item2}")
    puts("Jack's List:\n #{jack.items}")
    puts("John's List:\n #{john.items}")
    puts("Jack buys John's Gartentisch!")
    jack.buy(item1)
    puts("Jack's List:\n #{jack.items}")
    puts("John's List:\n #{john.items}")
    puts("John tries to buy Jack's DVD!")
    assert_raise(NameError){user.buy(item)}
    puts("Jack's List:\n #{jack.items}")
    puts("John's List:\n #{john.items}")
    puts("DVD Activation!")
    item2.active=true;
    puts("John tries again to buy Jack's DVD!")
    john.buy(item2)
    puts("Jack's List:\n #{jack.items}")
    puts("John's List:\n #{john.items}")
    puts("Le Fin!")

  end
end