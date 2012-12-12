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

  def setup

    @database = Marketplace::Database.instance

    @daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
    @joel = Marketplace::User.create('Joel','test','joel.guggisberg@students.unibe.ch')
    @lukas = Marketplace::User.create('Lukas','lol','lukas.v.rotz@gmail.com')

    @item1 = Marketplace::Item.create('Table', "No Description", 100, 20, @daniel)
    @item2 = Marketplace::Item.create('Inception, Dvd', "No Description", 10, 30, @joel)
    @item3 = Marketplace::Item.create('Bed', "No Description", 50, 2, @lukas)

  end

  def teardown
    Marketplace::Database.reset_database
  end

  def test_user_functions

    #user is included in database
    assert(@database.all_users.include?(@joel),"User not included")
    #the database gives the right user back when searching for names
    assert_not_equal(@database.user_by_name('John2'),@joel)
    assert(@database.email_exists?('test@testmail1.com'))
    #should have as many email addresses as user
    assert(@database.all_emails.size,3)
    users=@database.all_users
    #all user are added to the singleton database
    assert_equal(users.size,3)

    @database.delete_user(@joel)
    @database.deactivated_user_by_name("Lukas")

    users=@database.all_users
    #a user is removed
    assert_equal(users.size,2)

  end

  def test_item_functions

    @item1.active = true
    @item2.active = true
    @item3.active = false

    items = @database.all_active_items

    #the amount of activated is items correct
    assert_equal(items.size, 2)
    #the total should not be changed
    assert_equal(@database.all_items.size,3)

    @database.delete_item(@item1)
    items = @database.all_active_items

    #a deleted file is also from the active item removed
    assert_equal(items.size, 1)
    #the total should also be changed
    assert_equal(@database.all_items.size,2)

  end

  def test_buy_orders

    buy_order=  Marketplace::BuyOrder.create("Table",100,@lukas)
    buy_order2=  Marketplace::BuyOrder.create("Table",110,@lukas)

    #the number of orders is correct
    assert_equal(@database.all_buy_orders.size,2)
    #the right number of involved orders of a item is returned
    assert_equal(@database.call_buy_orders(@item2).size,2)

  end

  def test_verification

    timestamp = Time.new
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"

    #a new user is not verified
    assert(!@lukas.verified)

    @database.add_verification(hash, @lukas, timestamp)
    @database.verification_user_by_hash(hash).verify
    @database.delete_verification(hash)
    #a user is verified after submitting the correct hash
    assert(@lukas.verified)

  end

  def test_password_reset

    timestamp = Time.new - 7201
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"

    #reset pw can be called and removed by hash
    @database.add_pw_reset(hash,@joel,timestamp)
    assert(@database.pw_reset_has?(hash))
    @database.delete_pw_reset(hash)
    assert(!@database.pw_reset_has?(hash))

    #reset pw can expire because of the time
    @database.add_pw_reset(hash,@lukas,timestamp)
    assert(@database.pw_reset_has?(hash))
    @database.clean_pw_reset_older_as(2)
    assert(!@database.pw_reset_has?(hash))

  end

end