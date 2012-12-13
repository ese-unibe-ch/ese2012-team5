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

  def test_user_initialization
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
    @table.split(10)
    assert(@table.quantity,"Wrong split quantity")
    @user_items = @daniel.items
    @item4 = @user_items[3]
    assert(@table.mergeable?(@item4),"The same Items should be mergeable")
    assert(!@table.mergeable?(@chair),"Different Items should not be mergeable")
    @table.merge(@item4)
    assert(@table.quantity==20,"Wrong merge quantity")
  end

  def test_item_activate_deactivate
    @table.activate
    assert(@table.active,"Item should be active when activated")
    @table.deactivate
    assert(!@table.active,"Item should be inactive when deactivated")
    @table.switch_active
    assert(@table.active,"Item should be active when switechd from inactive")
    @table.switch_active
    assert(!@table.active,"Item should be inactive when switeched from active")
  end

  def test_item_description_and_description_log
    @time_now = Time.new
    @table.add_description(@time_now,"Number1",10)
    assert(@table.description=="Number1","descriptions is wrong")
    assert(@table.price==10,"price is wrong")
    assert(@table.description_log.length==2,"old description wasnt added to log")
    @table.add_description(Time.new,"Number2",20)
    assert(@table.description=="Number2","descriptions is wrong")
    assert(@table.price==20,"price is wrong")
    assert(@table.description_log.length==3,"old description wasnt added to log")

    assert(@table.description_from_log(@time_now)=="No Description","retrieving description from log failed")
    assert(@table.price_from_log(@time_now)==100,"retrieving price from log failed")

    assert(@table.status_changed("Number1",10),"Status has changed")
    assert(!@table.status_changed("Number2",20),"Status hasnt changed")

    @table.clean_description_log
    assert(@table.description_log.length==1,"old description should be deleted")
  end

  def test_item_image_handling
    @table.add_image("new_image.jpg")
    assert(@table.pictures[0]=="new_image.jpg","Images wasnt added")
    @table.add_image("new_image1.jpg")
    assert(@table.pictures[0]=="new_image.jpg","Images wasnt added")
    @table.select_front_image(1)
    assert(@table.pictures[0]=="new_image1.jpg","Images wasnt put in front")
  end

  def test_item_image_path
    assert(@table.image_path(0)=="/images/default_item.jpg","didnt get default image ")
    @table.add_image("xxx.jpg")
    assert(@table.image_path(0)=="/images/xxx.jpg","current image path is wrong")
  end

  def test_image_delete
    @table.delete
    assert(!@daniel.items.include?(@table),"Item should be deleted")
  end

end