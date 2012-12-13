require 'test/unit'
require 'rubygems'
require 'bcrypt'
require 'webget_ruby_secure_random'
require 'require_relative'

require_relative '../../app/models/marketplace/entity.rb'
require_relative '../../app/models/marketplace/user.rb'
require_relative '../../app/models/marketplace/activity.rb'
require_relative '../../app/models/marketplace/item.rb'
require_relative '../../app/models/marketplace/buy_order.rb'
require_relative '../../app/models/marketplace/database.rb'


class UserTest < Test::Unit::TestCase

  def setup
    @database = Marketplace::Database.instance

    @daniel = Marketplace::User.create('user1','pW123','test@testmail1.com')
    @joel = Marketplace::User.create('user2','pW123','test@testmail2.com')

    @table = Marketplace::Item.create('Table', "No Description", 100, 20, @daniel)
    @chair = Marketplace::Item.create('Chair', "No Description", 50, 20, @daniel)
    @book = Marketplace::Item.create('Book', "No Description", 50, 20, @daniel)
  end

  def teardown
    Marketplace::Database.reset_database
  end

  def test_user_initialization
    assert(!@daniel.name.nil? ,"user name is nil")
    assert_equal("user1", @daniel.name, "wrong User name")

    assert(!@daniel.password.nil? ,"password is nil")

    assert(!@daniel.email.nil? ,"email is nil")
    assert_equal("test@testmail1.com", @daniel.email, "wrong email")

    assert_equal(100, @daniel.credits, "wrong Credits")
    assert_equal(nil, @daniel.picture, "wrong Pic ")
    assert_equal("No description", @daniel.details, "wrong description")
    assert(!@daniel.verified, "wrong verified value")
    assert_equal(0, @daniel.subscriptions.length(), "wrong subscriptions length")
  end

  def test_user_has_enough_credits
    assert_equal(false, @daniel.has_enough_credits?(200), "wrong has_enough_credits method")
    assert_equal(true, @daniel.has_enough_credits?(9), "wrong has_enough_credits method")
  end

  def test_add_credits
    @daniel.add_credits(100)
    assert_equal(200, @daniel.credits, "wrong add_credits method")
  end

  def test_remove_credits
    @daniel.remove_credits(100)
    assert_equal(0, @daniel.credits, "wrong remove_credits_method")
  end

  def test_user_has_item
    assert(@daniel.has_item?(@table),"wrong has_item method")
    assert(!@joel.has_item?(@table),"wrong has_item method")
  end

  def test_user_items
    user1_items = @daniel.items
    assert(user1_items.include?(@table),"user items were not delivered correctly")
  end

  def test_user_subscriptions
    @daniel.add_subscription(@joel)
    assert(@daniel.subscriptions.include?(@joel),"user subscription was not added")
    @daniel.delete_subscription(@joel)
    assert(!@daniel.subscriptions.include?(@joel),"user subscription was not deleted")
  end

  def test_user_image_path
    assert(@daniel.image_path=="/images/default_user.jpg","didnt get default image ")
    @daniel.picture = "xxx.jpg"
    assert(@daniel.image_path=="/images/xxx.jpg","current image path is wrong")
  end

  def test_user_delete
    @daniel.delete
    assert(!Marketplace::Database.instance.all_users.include?(@daniel),"user1 should have been deleted")
  end

  def test_user_reactivation_system
    assert(Marketplace::Database.instance.all_users.include?(@daniel),"user1 should be in database")
    @daniel.deactivate
    assert(!Marketplace::Database.instance.all_users.include?(@daniel),"user1 should have been deactivated")
    assert_equal(0,Marketplace::Database.instance.buy_orders_by_user(@daniel).length,"there shouldnt be buyorders left")
    @daniel.activate
    assert(Marketplace::Database.instance.all_users.include?(@daniel),"user1 should be in database")
  end

  def test_user_trading
    @joel.add_credits(2000)
    @table.active = true

    assert_equal(@joel.items.size, 0)
    assert_equal(@daniel.items.size, 3)

    #is item still existing in the seller, if only a part is sold
    @joel.buy(@table, 1)

    assert_equal(@joel.items.size, 1)
    assert_equal(@daniel.items.size, 3)

    @joel.buy(@table, 19)

    #item disappears, if all items are sold
    assert_equal(@joel.items.size, 2)
    assert_equal(@daniel.items.size, 2)


    #users shouldn't be able to buy an inactive item for which they have no money and want more than exist
    assert(!@joel.can_buy_item?(@chair,2000))

    @chair.active = true
    @joel.add_credits(2000)

    assert(@joel.can_buy_item?(@chair,2))

    @table.active = true

    @daniel.buy(@table,5)
    assert_equal(@joel.items.size, 2)
    assert_equal(@daniel.items.size, 3)

  end

end