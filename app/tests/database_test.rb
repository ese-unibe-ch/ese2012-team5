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




class Database_Tests < Test::Unit::TestCase
  def test_user_functions
    database = Marketplace::Database.instance
    user = Marketplace::User.create('John','pW123','test@testmail1.com')
    user2 = Marketplace::User.create('John2','pW123','test@testmail2.com')

    assert(database.all_users.include?(user),"User not included")
    assert(database.user_by_name('John2')!=user)

    user1 = database.user_by_email('test@testmail1.com')

    assert(user2.name=="John2")


    users=database.all_users

    assert_equal(users.size,7)



    database.delete_user(user1)

    database.delete_deactivated_user(user1)

    users=database.all_users

    assert_equal(users.size,6)



    end

  def test_item_functions
    database = Marketplace::Database.instance

    daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
    joel = Marketplace::User.create('Joel','test','joel.guggisberg@students.unibe.ch')
    lukas = Marketplace::User.create('Lukas','lol','lukas.v.rotz@gmail.com')

    item1 = Marketplace::Item.create('Table', "No Description", 100, 20, daniel)
    item2 = Marketplace::Item.create('Inception, Dvd', "No Description", 10, 30, joel)
    item3 = Marketplace::Item.create('Bed', "No Description", 50, 2, lukas)

    item1.active = true
    item2.active = true
    item3.active = false


    items = database.all_active_items

    assert_equal(items.size, 2)


    #todo
  end

  def test_buy_orders
    database = Marketplace::Database.instance
    user = Marketplace::User.create('John','pW123','test@testmail1.com')
    user2 = Marketplace::User.create('John2','pW1232','test@testmail2.com')
    item1 = Marketplace::Item.create('Table', "No Description", 100, 20, user2)
    buy_order=  Marketplace::BuyOrder.create("Table",100,user)



    assert(database.all_buy_orders.size ==1)



  end

  def test_verification

    database = Marketplace::Database.instance
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"
    user = Marketplace::User.create('John','pW123','test@testmail1.com')
    timestamp = Time.new
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"


    assert(user.verified == false)

    database.add_verification(hash, user, timestamp)

    database.verification_user_by_hash(hash).verify

    database.delete_verification(hash)


    assert(user.verified == true)

  end

end