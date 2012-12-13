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

end