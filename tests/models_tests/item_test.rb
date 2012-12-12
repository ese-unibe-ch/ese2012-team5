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
    assert(!@item1.name.nil? ,"item name is nil")
    assert_equal("Table", @item1.name, "wrong item name")

    assert(!@item1.description.nil? ,"description is nil")
    assert_equal("No Description", @item1.description, "wrong description")

    assert(!@item1.price.nil? ,"price is nil")
    assert_equal(100, @item1.price, "wrong price")

    assert(!@item1.quantity.nil? ,"quantity is nil")
    assert_equal(20, @item1.quantity, "wrong quantity")

    assert(!@item1.owner.nil? ,"owner attribute is nil")
    assert_equal(@user1, @item1.owner, "wrong owner")

    assert(!@item1.pictures.nil? ,"pictures attribute is nil")
    assert_equal(0, @item1.pictures.length(), "wrong pictures length")

    assert(!@item1.description_log.nil? ,"description_log attribute is nil")
    assert_equal(1, @item1.description_log.length(), "wrong description_log length")

    assert(!@item1.id.nil? ,"id attribute is nil")
  end

  def test_item_split_and_merge
    @item1.split(10)
    assert(@item1.quantity,"Wrong split quantity")
    @user_items = @user1.items
    @item4 = @user_items[3]
    assert(@item1.mergeable?(@item4),"The same Items should be mergeable")
    assert(!@item1.mergeable?(@item2),"Different Items should not be mergeable")
    @item1.merge(@item4)
    assert(@item1.quantity==20,"Wrong merge quantity")
  end

  def test_item_activate_deactivate
    @item1.activate
    assert(@item1.active,"Item should be active when activated")
    @item1.deactivate
    assert(!@item1.active,"Item should be inactive when deactivated")
    @item1.switch_active
    assert(@item1.active,"Item should be active when switechd from inactive")
    @item1.switch_active
    assert(!@item1.active,"Item should be inactive when switeched from active")
  end

  def test_item_description_and_description_log
    @time_now = Time.new
    @item1.add_description(@time_now,"Number1",10)
    assert(@item1.description=="Number1","descriptions is wrong")
    assert(@item1.price==10,"price is wrong")
    assert(@item1.description_log.length==2,"old description wasnt added to log")
    @item1.add_description(Time.new,"Number2",20)
    assert(@item1.description=="Number2","descriptions is wrong")
    assert(@item1.price==20,"price is wrong")
    assert(@item1.description_log.length==3,"old description wasnt added to log")

    assert(@item1.description_from_log(@time_now)=="No Description","retrieving description from log failed")
    assert(@item1.price_from_log(@time_now)==100,"retrieving price from log failed")

    assert(@item1.status_changed("Number1",10),"Status has changed")
    assert(!@item1.status_changed("Number2",20),"Status hasnt changed")

    @item1.clean_description_log
    assert(@item1.description_log.length==1,"old description should be deleted")
  end

  def test_item_image_handling
    @item1.add_image("new_image.jpg")
    assert(@item1.pictures[0]=="new_image.jpg","Images wasnt added")
    @item1.add_image("new_image1.jpg")
    assert(@item1.pictures[0]=="new_image.jpg","Images wasnt added")
    @item1.select_front_image(1)
    assert(@item1.pictures[0]=="new_image1.jpg","Images wasnt put in front")
  end

  def test_item_image_path
    assert(@item1.image_path(0)=="/images/default_item.jpg","didnt get default image ")
    @item1.add_image("xxx.jpg")
    assert(@item1.image_path(0)=="/images/xxx.jpg","current image path is wrong")
  end

  def test_image_delete
    @item_test = @item1
    @item1.delete
    assert(!@user1.items.include?(@item_test),"Item should be deleted")
  end
end