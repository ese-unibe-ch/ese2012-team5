require "test/unit"
require 'rubygems'
#require 'sinatra'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'


require '../../../app/models/marketplace/entity.rb'
require '../../../app/models/marketplace/user.rb'
require '../../../app/models/marketplace/activity.rb'
require '../../../app/models/marketplace/user.rb'
require '../../../app/models/marketplace/item.rb'
require '../../../app/models/marketplace/buy_order.rb'
require '../../../app/models/marketplace/search_result.rb'
require '../../../app/models/marketplace/database.rb'
require '../../../app/helper/mailer.rb'
require '../../../app/helper/validator.rb'
require '../../../app/helper/checker.rb'
require '../../../app/helper/image_uploader.rb'

class User_Tests  < Test::Unit::TestCase

  def test_user_simple_caller

    user1 = Marketplace::User.create('user1','pW123','test@testmail1.com')

    assert_equal(user1.name, "user1")



  end

  def test_user_trading

    user1 = Marketplace::User.create('user1','pW123','test@testmail1.com')


    user2 = Marketplace::User.create('user2','pW123','test@testmail2.com')
    user2.add_credits(2000)

    item1 = Marketplace::Item.create('Table', "No Description", 100, 20, user1)
    item2 = Marketplace::Item.create('Chair', "No Description", 50, 20, user1)
    item1.active = true

    assert_equal(user2.items.size, 0)
    assert_equal(user1.items.size, 2)

    #is item still existing in the seller, if only a part is sold
    user2.buy(item1, 1)

    assert_equal(user2.items.size, 1)
    assert_equal(user1.items.size, 2)

    user2.buy(item1, 19)

    #item disappears, if all items are sold
    assert_equal(user2.items.size, 2)
    assert_equal(user1.items.size, 1)


    #users shouldn't be able to buy an inactive item for which they have no money and want more than exist
    assert(!user2.can_buy_item?(item2,2000))

    item2.active = true
    user2.add_credits(2000)

    assert(user2.can_buy_item?(item2,2))


  end

end