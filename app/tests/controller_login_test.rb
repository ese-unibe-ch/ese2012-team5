require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'tlsmail'
require 'require_relative'


require "rubygems"
require "selenium/webdriver"

require "test/unit"
require 'require_relative'



class Controller_Login_Test <Test::Unit::TestCase

def setup
  @driver = Selenium::WebDriver.for :firefox
  @driver.get("localhost:4567")
end
def teardown
  @driver.quit
end

def test_correct_user_name
  element = @driver.find_element :name => "username"
  element.send_keys "Daniel"
  element = @driver.find_element :name => "password"
  element.send_keys "hallo"
  element.submit


 # assert(element.text.include?("logged in"), "login was not successfull!")


  assert_equal(@driver.current_url, "http://localhost:4567/")
  assert_equal(@driver.title,"item|market")

end

def test_false_user_name
  element = @driver.find_element :name => "username"
  element.send_keys "Daniels"
  element = @driver.find_element :name => "password"
  element.send_keys "hallo"
  element.submit

  assert_equal(@driver.current_url, "http://localhost:4567/login")


end



end