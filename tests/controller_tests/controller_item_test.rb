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
require_relative '../../app/controllers/item.rb'
require_relative '../../app/controllers/item_activate.rb'
require_relative '../../app/controllers/item_create.rb'


class ControllerItemTest <Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567")
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit
  end

  def teardown
    @driver.quit
  end

  def test_item_status
    @driver.get("localhost:4567/item/14")
    element = @driver.find_element :name => "change_status"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("item is now inactive.") || element.text.include?("item is now active."), "item status could not be changed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
  end

  def test_item_valid_comment
    @driver.get("localhost:4567/item/14")
    element = @driver.find_element :name => "comment"
    element.send_keys "new_comment"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("added new comment to item"), "comment could not be added")
    assert_equal(@driver.current_url, "http://localhost:4567/item/14")
  end

  def test_item_invalid_comment
    @driver.get("localhost:4567/item/14")
    element = @driver.find_element :name => "comment"
    element.send_keys ""
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("comment was empty!"), "comment could not be added")
    assert_equal(@driver.current_url, "http://localhost:4567/item/14")
  end

  def test_item_add_valid
    @driver.get("localhost:4567/createItem")
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

  def test_item_add_invalid_name
    @driver.get("localhost:4567/createItem")
    element = @driver.find_element :name => "name"
    element.send_keys ""
    element = @driver.find_element :name => "price"
    element.send_keys "50"
    element = @driver.find_element :name => "quantity"
    element.send_keys "5"
    element = @driver.find_element :name => "description"
    element.send_keys "No Description"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("name was empty!"), "item was not created")
  end

  def test_item_add_invalid_price
    @driver.get("localhost:4567/createItem")
    element = @driver.find_element :name => "name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "price"
    element.send_keys "-1"
    element = @driver.find_element :name => "quantity"
    element.send_keys "5"
    element = @driver.find_element :name => "description"
    element.send_keys "No Description"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("price was smaller than minimum 1!"), "too small price not detected")

    @driver.get("localhost:4567/createItem")
    element = @driver.find_element :name => "name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "price"
    element.send_keys "a"
    element = @driver.find_element :name => "quantity"
    element.send_keys "5"
    element = @driver.find_element :name => "description"
    element.send_keys "No Description"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("price was not a number!"), "letter in price not detected")
  end

  def test_item_add_invalid_quantity
    @driver.get("localhost:4567/createItem")
    element = @driver.find_element :name => "name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "price"
    element.send_keys "50"
    element = @driver.find_element :name => "quantity"
    element.send_keys "-5"
    element = @driver.find_element :name => "description"
    element.send_keys "No Description"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("quantity was smaller than minimum 1!"), "too small quantity not detected")

    @driver.get("localhost:4567/createItem")
    element = @driver.find_element :name => "name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "price"
    element.send_keys "50"
    element = @driver.find_element :name => "quantity"
    element.send_keys "a"
    element = @driver.find_element :name => "description"
    element.send_keys "No Description"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("quantity was not a number!"), "letter in quantity not detected")
  end

  def test_item_add_invalid_description
    @driver.get("localhost:4567/createItem")
    element = @driver.find_element :name => "name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "price"
    element.send_keys "50"
    element = @driver.find_element :name => "quantity"
    element.send_keys "5"
    element = @driver.find_element :name => "description"
    element.send_keys ""
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("description was empty!"), "invalid description not detected")
  end
end