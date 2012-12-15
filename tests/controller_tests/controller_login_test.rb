require 'rubygems'
require 'sinatra'
require 'test/unit'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'tlsmail'
require 'require_relative'
require 'selenium/webdriver'

require_relative '../../app/controllers/login.rb'
require_relative '../../app/controllers/main.rb'


class ControllerLoginTest <Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567")
  end

  def teardown
    @driver.quit
  end

  def test_invalid_email
    element = @driver.find_element :link => "Register"
    element.click
    element = @driver.find_element :name => "username"
    element.send_keys "User1"
    element = @driver.find_element :name => "email"
    element.send_keys "invalid_mail"
    element = @driver.find_element :name => "password"
    element.send_keys "Hallo1"
    element = @driver.find_element :name => "password_conf"
    element.send_keys "Hallo1"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("email not valid!"), "wrong mail not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/register")
  end

  def test_correct_username
    element = @driver.find_element :name => "username"
    element.send_keys "Daniel"
    element = @driver.find_element :name => "password"
    element.send_keys "hallo"
    element.submit

    element = @driver.find_element :css => "h1"
    assert(element.text.include?("Welcome Daniel"), "login was not successfull!")
    assert_equal(@driver.current_url, "http://localhost:4567/")
    assert_equal(@driver.title,"item|market")
  end

  def test_wrong_username
    element = @driver.find_element :name => "username"
    element.send_keys "Daniels"
    element = @driver.find_element :name => "password"
    element.send_keys "hallo"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("user doesn't exist!"), "wrong username not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/login")
  end

  def test_wrong_password
    element = @driver.find_element :name => "username"
    element.send_keys "Daniel"
    element = @driver.find_element :name => "password"
    element.send_keys "penis"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("wrong password!!"), "wrong password not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/login")
  end

  def test_item_status
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    element = @driver.find_element :id => "first_entry"
    element.click
    element = @driver.find_element :name => "change_status"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("item is now inactive.") || element.text.include?("item is now active."), "item status could not be changed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
  end

  def test_item_comment
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    element = @driver.find_element :id => "first_entry"
    element.click
    element = @driver.find_element :name => "comment"
    element.send_keys "new_comment"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("added new comment to item"), "comment could not be added")
    assert_equal(@driver.current_url, "http://localhost:4567/item/14")
  end

  def test_item_add
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    element = @driver.find_element :link => "Add Item"
    element.click
    element = @driver.find_element :name => "name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "price"
    element.send_keys "50"
    element = @driver.find_element :name => "quantity"
    element.send_keys "5"
    element = @driver.find_element :name => "description"
    element.send_keys "No Description"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("you have created Item1"), "item was not created")
  end

  def test_buy_order
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    element = @driver.find_element :link => "Add BuyOrder"
    element.click
    element = @driver.find_element :name => "item_name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "max_price"
    element.send_keys "100"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("you have created a new buy order."), "buy order was not created")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
    element = @driver.find_element :link => "Logout"
    element.click

    element = @driver.find_element :name => "username"
    element.send_keys "Urs"
    element = @driver.find_element :name => "password"
    element.send_keys "123"
    element.submit

    element = @driver.find_element :link => "Add Item"
    element.click
    element = @driver.find_element :name => "name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "price"
    element.send_keys "80"
    element = @driver.find_element :name => "quantity"
    element.send_keys "1"
    element = @driver.find_element :name => "description"
    element.send_keys "No Description"
    element.submit
    element = @driver.find_element :name => "change_status"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("item was already sold!"), "buy order was not created")
    assert_equal(@driver.current_url, "http://localhost:4567/user/Urs")
  end

  def test_activity_log_item
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    element = @driver.find_element :link => "Table"
    element.click
    element = @driver.find_element :id => "follow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You are now following Table."), "item could not be followed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
    element = @driver.find_element :link => "ActivityLog"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("Table"), "you're not following table")
    element = @driver.find_element :link => "Home"
    element.click
    element = @driver.find_element :link => "Table"
    element.click
    element = @driver.find_element :id => "unfollow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You don't follow Table anymore!"), "item could not be unfollowed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
  end

  def test_activity_log_user
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    element = @driver.find_element :link => "Daniel"
    element.click
    element = @driver.find_element :id => "follow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You are now following Daniel."), "user could not be followed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
    element = @driver.find_element :link => "ActivityLog"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("Daniel"), "you're not following Daniel")
    element = @driver.find_element :link => "Home"
    element.click
    element = @driver.find_element :link => "Daniel"
    element.click
    element = @driver.find_element :id => "unfollow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You don't follow Daniel anymore!"), "user could not be unfollowed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
  end

  def test_user_delete_account
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit
    element = @driver.find_element :link => "Settings"
    element.click
    element = @driver.find_element :id => "confirm_deleting"
    element.click
    element = @driver.find_element :id => "password_deleting"
    element.send_keys "ese"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("account deleted."), "account couldnt be deleted")
    assert_equal(@driver.current_url, "http://localhost:4567/")
  end

  def test_user_deactivate_account
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit
    element = @driver.find_element :link => "Settings"
    element.click
    element = @driver.find_element :id => "confirm_deactivation"
    element.click
    element = @driver.find_element :id => "password_deactivation"
    element.send_keys "ese"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("account deactivated."), "account couldnt be deactivated")
    assert_equal(@driver.current_url, "http://localhost:4567/")

    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("user reactivated!"), "account couldnt be reactivated")
    assert_equal(@driver.current_url, "http://localhost:4567/")
  end

  def test_user_change_description
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit
    element = @driver.find_element :link => "Settings"
    element.click
    element = @driver.find_element :name => "details"
    element.send_keys "new description"
    element.submit
    assert_equal(@driver.current_url, "http://localhost:4567/settings")
    element = @driver.find_element :link => "Your profile"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("new description"), "description wasnt added")
  end

  def test_menu_points
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    element = @driver.find_element :link => "Home"
    element.click
    assert_equal(@driver.current_url, "http://localhost:4567/")
    element = @driver.find_element :link => "Your profile"
    element.click
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
    element = @driver.find_element :link => "Add Item"
    element.click
    assert_equal(@driver.current_url, "http://localhost:4567/createItem")
    element = @driver.find_element :link => "Add BuyOrder"
    element.click
    assert_equal(@driver.current_url, "http://localhost:4567/createBuyOrder")
    element = @driver.find_element :link => "ActivityLog"
    element.click
    assert_equal(@driver.current_url, "http://localhost:4567/activity_log/5")
    element = @driver.find_element :link => "Settings"
    element.click
    assert_equal(@driver.current_url, "http://localhost:4567/settings")
    element = @driver.find_element :link => "Logout"
    element.click
    assert_equal(@driver.current_url, "http://localhost:4567/login")
  end
end