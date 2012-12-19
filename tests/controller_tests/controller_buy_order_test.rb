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
require_relative '../../app/controllers/buy_order_create.rb'
require_relative '../../app/controllers/item.rb'
require_relative '../../app/controllers/item_activate.rb'


class ControllerBuyOrderTest <Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567")
  end

  def teardown
    @driver.quit
  end

  def test_buy_order
    element = @driver.find_element :name => "username"
    element.send_keys "ese"
    element = @driver.find_element :name => "password"
    element.send_keys "ese"
    element.submit

    @driver.get("http://localhost:4567/create_buy_order")
    element = @driver.find_element :name => "item_name"
    element.send_keys ""
    element = @driver.find_element :name => "max_price"
    element.send_keys "100"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("name was empty!"), "buy order was not created")
    assert_equal(@driver.current_url, "http://localhost:4567/create_buy_order")

    element = @driver.find_element :name => "item_name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "max_price"
    element.send_keys "-1"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("max price was smaller than minimum 1!"), "too small price not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/create_buy_order")

    element = @driver.find_element :name => "item_name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "max_price"
    element.send_keys "a"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("max price was not a number!"), "letter in price not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/create_buy_order")

    element = @driver.find_element :name => "item_name"
    element.send_keys "Item1"
    element = @driver.find_element :name => "max_price"
    element.send_keys "100"
    element.submit
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("you have created a new buy order."), "buy order was not created")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
    @driver.get("http://localhost:4567/logout")

    element = @driver.find_element :name => "username"
    element.send_keys "Urs"
    element = @driver.find_element :name => "password"
    element.send_keys "123"
    element.submit

    @driver.get("http://localhost:4567/create_item")
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
    assert(element.text.include?("item was already sold"), "item not directly sold")
    assert_equal(@driver.current_url, "http://localhost:4567/user/Urs")
  end
end