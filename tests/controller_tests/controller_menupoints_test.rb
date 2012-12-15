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
require_relative '../../app/controllers/user.rb'
require_relative '../../app/controllers/item.rb'
require_relative '../../app/controllers/buy_order_create.rb'
require_relative '../../app/controllers/item_create.rb'
require_relative '../../app/controllers/activity_log.rb'
require_relative '../../app/controllers/settings.rb'


class ControllerMenupointsTest <Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567")
  end

  def teardown
    @driver.quit
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