require 'test/unit'
require 'rubygems'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'

require_relative '../../app/models/marketplace/entity.rb'
require_relative '../../app/models/marketplace/user.rb'
require_relative '../../app/models/marketplace/activity.rb'
require_relative '../../app/models/marketplace/user.rb'
require_relative '../../app/models/marketplace/item.rb'
require_relative '../../app/models/marketplace/buy_order.rb'
require_relative '../../app/models/marketplace/search_result.rb'
require_relative '../../app/models/marketplace/database.rb'
require_relative '../../app/helper/mailer.rb'
require_relative '../../app/helper/validator.rb'
require_relative '../../app/helper/checker.rb'
require_relative '../../app/helper/image_uploader.rb'


class Database_Tests < Test::Unit::TestCase

  def setup
    @database = Marketplace::Database.instance

    @daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
    @joel = Marketplace::User.create('Joel','test','joel.guggisberg@students.unibe.ch')
    @lukas = Marketplace::User.create('Lukas','lol','lukas.v.rotz@gmail.com')

    @daniel.verify
    @joel.verify

    @table = Marketplace::Item.create('Table', "No Description", 100, 20, @lukas)
    @dvd = Marketplace::Item.create('Inception, Dvd', "No me", 10, 30, @joel)
    @bed1 = Marketplace::Item.create('Bed', "No Description", 44, 6, @daniel)
    @bed2 = Marketplace::Item.create('Bed', "find me", 50, 2, @lukas)

    @table.activate
    @dvd.activate
    @bed1.activate
    @bed2.activate
  end

  def teardown
    Marketplace::Database.reset_database
  end


  #--------
  #User
  #--------

  def test_delete_and_add_user_to_database
    assert_equal(@database.all_users.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_emails.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_deactivated_users.size, 0, "not exactly 0 deactivated users in database")

    @joel.delete

    assert_equal(@database.all_users.size, 2, "not exactly 2 users in database")
    assert_equal(@database.all_emails.size, 2, "not exactly 2 users in database")
    assert_equal(@database.all_deactivated_users.size, 0, "not exactly 0 deactivated users in database")

    urs = Marketplace::User.create('Urs','123','urs@home.ch')
    assert_equal(@database.user_by_name(urs.name), urs, "Urs has not beed added to database")

    assert_equal(@database.all_users.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_emails.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_deactivated_users.size, 0, "not exactly 0 deactivated users in database")
  end

  def test_deactivate_and_activate_user_in_database
    assert_equal(@database.all_users.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_emails.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_deactivated_users.size, 0, "not exactly 0 deactivated users in database")

    @joel.deactivate

    assert_equal(@database.all_users.size, 2, "not exactly 2 users in database")
    assert_equal(@database.all_emails.size, 2, "not exactly 2 users in database")
    assert_equal(@database.all_deactivated_users.size, 1, "not exactly 1 deactivated users in database")
    assert_equal(@database.deactivated_user_by_name(@joel.name), @joel, "Joel has not beed deactivated in database")

    @joel.activate

    assert_equal(@database.all_users.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_emails.size, 3, "not exactly 3 users in database")
    assert_equal(@database.all_deactivated_users.size, 0, "not exactly 0 deactivated users in database")
    assert_equal(@database.deactivated_user_by_name(@joel.name), nil, "Joel has not beed deactivated in database")
  end

  def test_user_joel_exists_in_database
    assert(@database.all_users.include?(@joel), "joel is not in database")
    assert_equal(@database.user_by_name('ET'), nil, "ET exists! RUN!")
    assert_equal(@database.user_by_name(@joel.name), @joel, "not correct Joel recieved!")
  end

  def test_email_in_database
    assert(@database.all_emails.include?(@joel.email), "joel is not in database")
    assert_equal(@database.user_by_email('ET@earth.com'), nil, "ET exists! RUN!")
    assert(@database.email_exists?(@joel.email), "Joel don't exists!")
    assert_equal(@database.user_by_email(@joel.email), @joel, "not correct Joel recieved!")
  end

  #--------
  #Items
  #--------

  def test_delete_and_add_item_to_database
    assert_equal(@database.all_items.size, 4, "not exactly 4 items in database")

    @bed2.delete

    assert_equal(@database.all_items.size, 3, "not exactly 3 items in database")

    hat = Marketplace::Item.create('Hat',"No Description", 22, 3, @lukas)
    assert_equal(@database.item_by_name(hat.name), [hat], "Hat has not been added to database")

    assert_equal(@database.all_items.size, 4, "not exactly 4 items in database")
  end

  def test_deactivate_and_activate_items_in_database
    assert_equal(@database.all_items.size, 4, "not exactly 4 items in database")
    assert_equal(@database.all_active_items.size, 4, "not exactly 4 active items in database")

    @table.deactivate

    assert_equal(@database.all_items.size, 4, "not exactly 4 items in database")
    assert_equal(@database.all_active_items.size, 3, "not exactly 3 active items in database")

    @table.activate

    assert_equal(@database.all_items.size, 4, "not exactly 4 items in database")
    assert_equal(@database.all_active_items.size, 4, "not exactly 4 active items in database")
  end

  def test_item_by_user
    items_of_joel = @database.items_by_user(@joel)
    assert_equal(items_of_joel, [@dvd], "joel has diffrent items!")

    items_of_lukas = @database.items_by_user(@lukas)
    assert_equal(items_of_lukas, [@table, @bed2], "lukas has diffrent items!")
  end

  def test_item_table_exists_in_database
    assert(@database.all_items.include?(@table), "table is not in database")
    assert_equal(@database.item_by_name('star'), [], "star exists?!")
    assert_equal(@database.item_by_name(@table.name), [@table], "not correct Table recieved with name!")
    assert_equal(@database.item_by_id(@table.id), @table, "not correct Table recieved with id!")
  end

  def test_item_both_beds_exists_in_database
    assert(@database.all_items.include?(@bed1), "bed1 is not in database")
    assert(@database.all_items.include?(@bed2), "bed2 is not in database")

    assert_equal(@database.item_by_name(@bed1.name), [@bed1, @bed2], "not correct beds have been recieved with name!")
    assert_equal(@database.item_by_id(@bed1.id), @bed1, "not correct Table recieved with id!")
  end

  #--------
  #BuyOrders
  #--------

  def test_buy_orders

    #TODO write good buy_order test!
    buy_order1 = Marketplace::BuyOrder.create("Table", 100, @lukas)
    buy_order2 = Marketplace::BuyOrder.create("Table", 110, @lukas)

    assert_equal(@database.all_buy_orders.size, 2, "size of buy_orders not 2!")
  end


  #--------
  #Verifications
  #--------

  def test_verify_user_lukas
    timestamp = Time.now
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"

    assert(!@lukas.verified, "lukas is already verified!")

    @database.add_verification(hash, @lukas, timestamp)
    assert(@database.verification_has?(hash), "verification with hash not found in database")

    user_to_verify = @database.verification_user_by_hash(hash)
    user_to_verify.verify
    assert(user_to_verify.verified, "lukas has not been verified")

    @database.delete_verification(hash)
    assert(!@database.verification_has?(hash), "verification with hash has not been deleted from database")
  end

  #--------
  #PasswordResets
  #--------

  def test_password_reset_add_and_remove_from_database
    timestamp = Time.now + 3600
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"

    @database.add_pw_reset(hash, @joel, timestamp)
    assert(@database.pw_reset_has?(hash), "pw_reset with hash not found in database")

    @database.delete_pw_reset(hash)
    assert(!@database.pw_reset_has?(hash), "pw_reset with hash has not been deleted from database")
  end

  def test_password_reset_expire_in_database
    timestamp = Time.now - 4000
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"

    @database.add_pw_reset(hash, @lukas, timestamp)
    assert(@database.pw_reset_has?(hash), "pw_reset with hash not found in database")

    @database.clean_pw_reset_older_as(1)
    assert(!@database.pw_reset_has?(hash),  "pw_reset with hash has not been deleted due expiration")
  end

end