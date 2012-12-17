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
require_relative '../../app/controllers/user.rb'
require_relative '../../app/controllers/activity_log.rb'
require_relative '../../app/controllers/item_follow.rb'
require_relative '../../app/controllers/user_follow.rb'


class ControllerActivityLogTest <Test::Unit::TestCase

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

  def test_activity_log_item
    @driver.get("localhost:4567/item/1")
    element = @driver.find_element :id => "follow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You are now following Table."), "item could not be followed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
    @driver.get("http://localhost:4567/activity_log/5")
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("Table"), "you're not following table")
    @driver.get("localhost:4567/item/1")
    element = @driver.find_element :id => "unfollow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You don't follow Table anymore!"), "item could not be unfollowed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
  end

  def test_activity_log_user
    @driver.get("localhost:4567/user/Daniel")
    element = @driver.find_element :id => "follow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You are now following Daniel."), "user could not be followed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
    @driver.get("http://localhost:4567/activity_log/5")
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("Daniel"), "you're not following Daniel")
    @driver.get("localhost:4567/user/Daniel")
    element = @driver.find_element :id => "unfollow"
    element.click
    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("You don't follow Daniel anymore!"), "user could not be unfollowed")
    assert_equal(@driver.current_url, "http://localhost:4567/user/ese")
  end
end