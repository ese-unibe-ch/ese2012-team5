require 'test/unit'
require 'rubygems'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'

require_relative '../../app/models/marketplace/entity.rb'
require_relative '../../app/models/marketplace/activity.rb'
require_relative '../../app/models/marketplace/user.rb'
require_relative '../../app/models/marketplace/item.rb'
require_relative '../../app/models/marketplace/database.rb'


class ItemTest < Test::Unit::TestCase

  def setup
    @datebase = Marketplace::Database.instance

    @daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
    @joel = Marketplace::User.create('Joel','test','test@testmail2.com')

    @table = Marketplace::Item.create('Table', "No Description", 100, 20, @daniel)
    @chair = Marketplace::Item.create('Chair', "No Description", 50, 20, @daniel)
    @book = Marketplace::Item.create('Book', "No Description", 50, 20, @daniel)
  end

  def teardown
    Marketplace::Database.reset_database
  end

  def test_item_initialization
    assert(!@table.name.nil? ,"item name is nil")
    assert_equal("Table", @table.name, "wrong item name")

    assert(!@table.description.nil? ,"description is nil")
    assert_equal("No Description", @table.description, "wrong description")

    assert(!@table.price.nil? ,"price is nil")
    assert_equal(100, @table.price, "wrong price")

    assert(!@table.quantity.nil? ,"quantity is nil")
    assert_equal(20, @table.quantity, "wrong quantity")

    assert(!@table.owner.nil? ,"owner attribute is nil")
    assert_equal(@daniel, @table.owner, "wrong owner")

    assert(!@table.pictures.nil? ,"pictures attribute is nil")
    assert_equal(0, @table.pictures.length(), "wrong pictures length")

    assert(!@table.description_log.nil? ,"description_log attribute is nil")
    assert_equal(1, @table.description_log.length(), "wrong description_log length")

    assert(!@table.id.nil? ,"id attribute is nil")
  end

  def test_item_split_and_merge
    table_rest = @table.split(8)
    assert_equal(@table.quantity, 12, "wrong split quantity")
    assert_equal(table_rest.quantity, 8, "wrong split quantity")


    assert(@table.mergeable?(table_rest), "same items should be mergeable")
    assert(!@table.mergeable?(@chair), "different items should not be mergeable")

    @table.merge(table_rest)
    assert_equal(@table.quantity, 20, "wrong merge quantity")
  end

  def test_item_activate_deactivate
    @table.activate
    assert(@table.active, "item should be active when activated")
    @table.deactivate
    assert(!@table.active, "item should be inactive when deactivated")
    @table.switch_active
    assert(@table.active, "item should be active when switechd from inactive")
    @table.switch_active
    assert(!@table.active, "item should be inactive when switeched from active")
  end

  def test_item_description_and_description_log
    time_now = Time.now

    @table.add_description(time_now, "Number1", 10)
    assert_equal(@table.description, "Number1", "descriptions is wrong")
    assert_equal(@table.price, 10, "price is wrong")
    assert_equal(@table.description_log.length, 2, "old description wasnt added to log")

    @table.add_description(Time.new, "Number2", 20)
    assert_equal(@table.description, "Number2", "descriptions is wrong")
    assert_equal(@table.price, 20, "price is wrong")
    assert_equal(@table.description_log.length, 3, "old description wasnt added to log")

    assert_equal(@table.description_from_log(time_now), "No Description", "retrieving description from log failed")
    assert_equal(@table.price_from_log(time_now), 100, "retrieving price from log failed")

    assert(@table.status_changed("Number1",10), "status has changed")
    assert(!@table.status_changed("Number2",20), "status hasn't changed")

    @table.clean_description_log
    assert_equal(@table.description_log.length, 1, "old description should be deleted")
  end

  def test_item_image_handling
    @table.add_image("new_image.jpg")
    assert_equal(@table.pictures[0], "new_image.jpg", "images wasnt added")
    @table.add_image("new_image1.jpg")
    assert_equal(@table.pictures[1], "new_image1.jpg", "images wasnt added")
    @table.select_front_image(1)
    assert_equal(@table.pictures[0], "new_image1.jpg", "images wasnt put in front")
  end

  def test_item_image_path
    assert_equal(@table.image_path(0), "/images/default_item.jpg", "didnt get default image ")
    @table.add_image("xxx.jpg")
    assert_equal(@table.image_path(0), "/images/xxx.jpg", "current image path is wrong")
  end

  def test_image_delete
    @table.delete
    assert(!@daniel.items.include?(@table), "item should be deleted")
  end

end