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
require_relative '../../app/controllers/delete_account.rb'
require_relative '../../app/controllers/deactivate_account.rb'
require_relative '../../app/controllers/settings.rb'


class ControllerUserTest <Test::Unit::TestCase

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

  def test_user_delete_account
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
end