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
    assert_equal(@daniel.password, 'pW123', "wrong password")

    assert(!@daniel.email.nil? ,"email is nil")
    assert_equal("test@testmail1.com", @daniel.email, "wrong email")

    assert_equal(100, @daniel.credits, "wrong Credits")

    assert_nil(@daniel.picture, "wrong profile picture")

    assert_equal("No description", @daniel.details, "wrong description")

    assert(!@daniel.verified, "wrong verified value")

    assert_equal(0, @daniel.subscriptions.length(), "wrong subscriptions length")
  end

  def test_user_has_enough_credits
    assert(!@daniel.has_enough_credits?(200), "shouldn't have enough credits")
    assert(@daniel.has_enough_credits?(9), "should have enough credits")
  end

  def test_add_credits
    assert_equal(100, @daniel.credits, "not correct amount of credits")
    @daniel.add_credits(100)
    assert_equal(200, @daniel.credits, "not correct amount of credits")
  end

  def test_remove_credits
    assert_equal(100, @daniel.credits, "not correct amount of credits")
    @daniel.remove_credits(100)
    assert_equal(0, @daniel.credits,  "not correct amount of credits")
  end

  def test_user_has_item
    assert(@daniel.has_item?(@table), "user should have table")
    assert(!@joel.has_item?(@table), "user shouldn't have table")
  end

  # NOTE user.items doesn't need to be tested, its only a wrapper around DB.items_by_user(user)
  # use DB test to check if working correct

  def test_user_subscriptions
    assert(!@daniel.subscriptions.include?(@joel), "user already have this subscription")
    @daniel.add_subscription(@joel)
    assert(@daniel.subscriptions.include?(@joel), "user subscription was not added")
    @daniel.delete_subscription(@joel)
    assert(!@daniel.subscriptions.include?(@joel), "user subscription was not deleted")
  end

  def test_user_image_path
    assert_equal(@daniel.image_path, "/images/default_user.jpg", "didnt get default image ")
    @daniel.picture = "xxx.jpg"
    assert_equal(@daniel.image_path, "/images/xxx.jpg", "current image path is wrong")
  end

  def test_user_delete
    assert(@database.all_users.include?(@daniel), "daniel should exist")
    @daniel.delete
    assert(!@database.all_users.include?(@daniel), "daniel should have been deleted")
  end

  def test_user_deactivate_and_reactivate
    assert(@database.all_users.include?(@daniel), "user1 should be in database")

    @daniel.deactivate
    assert(!@database.all_users.include?(@daniel), "user1 should have been deactivated")
    assert_equal(0, @database.buy_orders_by_user(@daniel).length, "there shouldnt be buyorders left")

    @daniel.activate
    assert(@database.all_users.include?(@daniel), "user1 should be in database")
  end

  def test_user_buy_only_parts_of_a_item
    @joel.add_credits(2000)
    @table.active = true

    assert_equal(@joel.items.size, 0, "joel has items")
    assert_equal(@daniel.items.size, 3, "daniel don't own exactly 3 items")
    assert_equal(@table.quantity, 20, "tables quantity isn't 20")

    @joel.buy(@table, 4)

    assert_equal(@joel.items.size, 1, "joel didn't recive a item")
    assert_equal(@daniel.items.size, 3, "daniel don't own exactly 3 items")

    joels_table = @joel.items[0]
    daniels_table = @table
    assert_equal(joels_table.quantity, 4, "joels table has not quantity 4")
    assert_equal(daniels_table.quantity, 16, "daniels table has not quantity 16")

    @joel.buy(@table, 16)

    assert_equal(@joel.items.size, 2)
    assert_equal(@daniel.items.size, 2)

    joels_table = @joel.items[0] #NOTE the first item in items is != the prevoius first item in items
    assert_equal(joels_table.quantity, 16, "joels second table has not quantity 16")
    assert_equal(joels_table, @table, "daniels'ex table should be joels table")
  end

  def test_user_can_or_cant_buy_item
    assert(!@joel.can_buy_item?(@chair, 20))

    @chair.active = true
    @joel.add_credits(200000)
    assert(@joel.can_buy_item?(@chair, 20))

    @joel.buy(@chair, 20)
    assert_equal(@joel.items.size, 1)
    assert_equal(@daniel.items.size, 2)
  end

end