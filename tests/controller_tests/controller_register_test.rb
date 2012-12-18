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


class ControllerRegisterTest <Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @driver.get("localhost:4567")
  end

  def teardown
    @driver.quit
  end

  def test_invalid_username
    @driver.get("localhost:4567/register")
    element = @driver.find_element :id => "username_register"
    element.send_keys ""
    element = @driver.find_element :id => "email_register"
    element.send_keys "valid_mail@lalala.com"
    element = @driver.find_element :id => "password_register"
    element.send_keys "Hallo1"
    element = @driver.find_element :id => "password_conf_register"
    element.send_keys "Hallo1"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("username too short."), "too short username not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/register")
  end

  def test_invalid_email
    @driver.get("localhost:4567/register")
    element = @driver.find_element :id => "username_register"
    element.send_keys "User1"
    element = @driver.find_element :id => "email_register"
    element.send_keys "invalid_mail"
    element = @driver.find_element :id => "password_register"
    element.send_keys "Hallo1"
    element = @driver.find_element :id => "password_conf_register"
    element.send_keys "Hallo1"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("email not valid!"), "wrong mail not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/register")
  end

  def test_invalid_password_too_short
    @driver.get("localhost:4567/register")
    element = @driver.find_element :id => "username_register"
    element.send_keys "User1"
    element = @driver.find_element :id => "email_register"
    element.send_keys "valid_mail@lalala.com"
    element = @driver.find_element :id => "password_register"
    element.send_keys "Hi"
    element = @driver.find_element :id => "password_conf_register"
    element.send_keys "Hi"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("password too short!"), "too short password not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/register")
  end

  def test_invalid_password_no_number
    @driver.get("localhost:4567/register")
    element = @driver.find_element :id => "username_register"
    element.send_keys "User1"
    element = @driver.find_element :id => "email_register"
    element.send_keys "valid_mail@lalala.com"
    element = @driver.find_element :id => "password_register"
    element.send_keys "Hallo"
    element = @driver.find_element :id => "password_conf_register"
    element.send_keys "Hallo"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("no number in password!"), "no number in password not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/register")
  end

  def test_invalid_password_no_uppercase
    @driver.get("localhost:4567/register")
    element = @driver.find_element :id => "username_register"
    element.send_keys "User1"
    element = @driver.find_element :id => "email_register"
    element.send_keys "valid_mail@lalala.com"
    element = @driver.find_element :id => "password_register"
    element.send_keys "hallo1"
    element = @driver.find_element :id => "password_conf_register"
    element.send_keys "hallo1"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("no uppercase letter in password!"), "no uppercase letter in password not detected")
    assert_equal(@driver.current_url, "http://localhost:4567/register")
  end

  def test_valid_registration
    @driver.get("localhost:4567/register")
    element = @driver.find_element :id => "username_register"
    element.send_keys "User2"
    element = @driver.find_element :id => "email_register"
    element.send_keys "valid_mail2@lalala.com"
    element = @driver.find_element :id => "password_register"
    element.send_keys "Hallo12"
    element = @driver.find_element :id => "password_conf_register"
    element.send_keys "Hallo12"
    element.submit

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("User2 created."), "user couldnt be created")
    assert_equal(@driver.current_url, "http://localhost:4567/")
  end
end