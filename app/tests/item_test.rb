require "test/unit"
require 'rubygems'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'


require '../../app/models/marketplace/entity.rb'
require '../../app/models/marketplace/user.rb'
require '../../app/models/marketplace/activity.rb'
require '../../app/models/marketplace/user.rb'
require '../../app/models/marketplace/item.rb'
require '../../app/models/marketplace/buy_order.rb'
require '../../app/models/marketplace/search_result.rb'
require '../../app/models/marketplace/database.rb'
require '../../app/helper/mailer.rb'
require '../../app/helper/validator.rb'
require '../../app/helper/checker.rb'
require '../../app/helper/image_uploader.rb'

class Item_Test < Test::Unit::TestCase


  def test_item


    database = Marketplace::Database.create_for_testing
    user = Marketplace::User.create('John','pW123','test@testmail1.com')
    user2 = Marketplace::User.create('John2','pW1232','test@testmail2.com')
    item1 = Marketplace::Item.create('Table', "No Description", 100, 20, user2)
    item2 = Marketplace::Item.create('Bed', "No Description", 100, 20, user2)
    item3 = Marketplace::Item.create('Table', "No Description", 100, 210, user2)
    buy_order=  Marketplace::BuyOrder.create("Table",100,user)
    buy_order2=  Marketplace::BuyOrder.create("Bed",110,user)

    assert(!item1.mergeable?(item2))
    assert(item1.mergeable?(item3))

    item1.activate

    assert(item1.mergeable?(item3))


    time_stamp= Time.new + 1
    item1.add_description(time_stamp, "Very nice Table", 300)

    time_stamp2= Time.new + 2
    item1.add_description(time_stamp2, "Even better Table", 600)


    #the time stamp leads to the correct details
    assert(item1.description_from_log(time_stamp)=="Very nice Table")
    assert(item1.price_from_log(time_stamp)==300)

    assert(item1.description_from_log(time_stamp2)=="Even better Table")
    assert(item1.price_from_log(time_stamp2)==600)


  end

end