require 'test/unit'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'

# syntax for inheritance
class StoreSimulationTest < Test::Unit::TestCase

  def test_simu
    john = Marketplace::User.create('John')
    jack = Marketplace::User.create('Jack')
    item1 = Marketplace::Item.create('Gartentisch XL', 50, john)
    item1.active=true
    item2 = Marketplace::Item.create('DVD', 10, jack)
    puts("Gartentisch Item: #{item1}")
    puts("DVD Item: #{item2}")
    puts("Jack's List:\n #{jack.items}")
    puts("John's List:\n #{john.items}")
    puts("Jack buys John's Gartentisch!")
    jack.buy(item1)
    puts("Jack's List:\n #{jack.items}")
    puts("John's List:\n #{john.items}")
    puts("John tries to buy Jack's DVD!")
    john.buy(item2)
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