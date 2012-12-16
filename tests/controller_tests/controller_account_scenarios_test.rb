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
require_relative '../../app/controllers/register.rb'
require_relative '../../app/controllers/delete_account.rb'
require_relative '../../app/controllers/verify.rb'

class ControllerAccountScenariosTest < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://localhost:4567"
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []

    #Testing Securerom Gem
    mail_extention ="@trash-mail.com"
    @username = SecureRandom.hex(5)
    @random_email = @username+mail_extention
    assert(@random_email.size == mail_extention.size + 10)
  end

  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end

  def test_register_scenario
    @driver.get(@base_url + "/")


    @driver.find_element(:xpath, "(//a[contains(text(),'Register')])[2]").click
    sleep 2
    @driver.find_element(:xpath, "(//input[@name='username'])[2]").clear
    @driver.find_element(:xpath, "(//input[@name='username'])[2]").send_keys @username
    @driver.find_element(:name, "email").clear
    @driver.find_element(:name, "email").send_keys @random_email
    @driver.find_element(:xpath, "(//input[@name='password'])[2]").clear
    @driver.find_element(:xpath, "(//input[@name='password'])[2]").send_keys "guessM33"
    @driver.find_element(:name, "password_conf").clear
    @driver.find_element(:name, "password_conf").send_keys "guessM33"
    @driver.find_element(:css, "td > input[type=\"submit\"]").click

    @driver.get("http://trash-mail.com/index.php")
    @driver.find_element(:name, "mail").click
    @driver.find_element(:name, "mail").clear
    @driver.find_element(:name, "mail").send_keys @username
    @driver.find_element(:name, "submit").click

    sleep 30 #Seconds to wait for email
    @driver.find_element(:name, "submit").click
    @driver.find_element(:link, "itemmarket.mail@gmai...").click

    element = @driver.find_element(:partial_link_text, "verify_account")
    href = element.attribute("href")
    @driver.get(href)

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("account is now activated"), "account was not activated")
  end
end