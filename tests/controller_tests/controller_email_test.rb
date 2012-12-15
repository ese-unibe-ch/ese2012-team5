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
require_relative '../../app/controllers/register.rb'


class ControllerEmailTest <Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567")
  end

  def teardown
    @driver.quit
  end

  def test_invalid_email
    @driver.get("localhost:4567/register")
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
end