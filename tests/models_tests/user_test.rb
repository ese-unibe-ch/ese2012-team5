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

class User_Tests  < Test::Unit::TestCase
  @user1
  @user2
  @item1
  @item2
  @item3
  @database

  def setup
    @user1 = Marketplace::User.create('user1','pW123','test@testmail1.com')
    @user2 = Marketplace::User.create('user2','pW123','test@testmail2.com')
    @item1 = Marketplace::Item.create('Table', "No Description", 100, 20, @user1)
    @item2 = Marketplace::Item.create('Chair', "No Description", 50, 20, @user1)
    @item3 = Marketplace::Item.create('Book', "No Description", 50, 20, @user1)
  end

  def teardown
    Marketplace::Database.reset_database
  end

  def test_user_initialization
    assert(!@user1.name.nil? ,"user name is nil")
    assert_equal("user1", @user1.name, "wrong User name")

    assert(!@user1.password.nil? ,"password is nil")

    assert(!@user1.email.nil? ,"email is nil")
    assert_equal("test@testmail1.com", @user1.email, "wrong email")

    assert_equal(100, @user1.credits, "wrong Credits")
    assert_equal(nil, @user1.picture, "wrong Pic ")
    assert_equal("No description", @user1.details, "wrong description")
    assert(!@user1.verified, "wrong verified value")
    assert_equal(0, @user1.subscriptions.length(), "wrong subscriptions length")
  end

  def test_user_has_enough_credits
    assert_equal(false, @user1.has_enough_credits?(200), "wrong has_enough_credits method")
    assert_equal(true, @user1.has_enough_credits?(9), "wrong has_enough_credits method")
  end

  def test_add_credits
    @user1.add_credits(100)
    assert_equal(200, @user1.credits, "wrong add_credits method")
  end

  def test_remove_credits
    @user1.remove_credits(100)
    assert_equal(0, @user1.credits, "wrong remove_credits_method")
  end

  def test_user_has_item
    assert(@user1.has_item?(@item1),"wrong has_item method")
    assert(!@user2.has_item?(@item1),"wrong has_item method")
  end

  def test_user_items
    user1_items = @user1.items
    assert(user1_items.include?(@item1),"user items were not delivered correctly")
  end

  def test_user_subscriptions
    @user1.add_subscription(@user2)
    assert(@user1.subscriptions.include?(@user2),"user subscription was not added")
    @user1.delete_subscription(@user2)
    assert(!@user1.subscriptions.include?(@user2),"user subscription was not deleted")
  end

  def test_user_image_path
    assert(@user1.image_path=="/images/default_user.jpg","didnt get default image ")
    @user1.picture = "xxx.jpg"
    assert(@user1.image_path=="/images/xxx.jpg","current image path is wrong")
  end

  def test_user_delete
    @user1.delete
    assert(!Marketplace::Database.instance.all_users.include?(@user1),"user1 should have been deleted")
  end

  def test_user_reactivation_system
    assert(Marketplace::Database.instance.all_users.include?(@user1),"user1 should be in database")
    @user1.deactivate
    assert(!Marketplace::Database.instance.all_users.include?(@user1),"user1 should have been deactivated")
    assert_equal(0,Marketplace::Database.instance.buy_orders_by_user(@user1).length,"there shouldnt be buyorders left")
    @user1.activate
    assert(Marketplace::Database.instance.all_users.include?(@user1),"user1 should be in database")
  end

  def test_user_trading
    @user2.add_credits(2000)
    @item1.active = true

    assert_equal(@user2.items.size, 0)
    assert_equal(@user1.items.size, 3)

    #is item still existing in the seller, if only a part is sold
    @user2.buy(@item1, 1)

    assert_equal(@user2.items.size, 1)
    assert_equal(@user1.items.size, 3)

    @user2.buy(@item1, 19)

    #item disappears, if all items are sold
    assert_equal(@user2.items.size, 2)
    assert_equal(@user1.items.size, 2)


    #users shouldn't be able to buy an inactive item for which they have no money and want more than exist
    assert(!@user2.can_buy_item?(@item2,2000))

    @item2.active = true
    @user2.add_credits(2000)

    assert(@user2.can_buy_item?(@item2,2))

    @item1.active = true

    @user1.buy(@item1,5)
    assert_equal(@user2.items.size, 2)
    assert_equal(@user1.items.size, 3)

  end

end