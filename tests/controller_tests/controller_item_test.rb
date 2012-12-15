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

  def test_item_comment
    @driver.get("localhost:4567/item/14")
    element = @driver.find_element :name => "comment"
    element.send_keys "new_comment"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("added new comment to item"), "comment could not be added")
    assert_equal(@driver.current_url, "http://localhost:4567/item/14")
  end

  def test_item_add
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
end