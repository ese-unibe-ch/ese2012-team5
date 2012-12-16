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

  def test_register_verify_scenario
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

    sleep 35 #Seconds to wait for email
    @driver.find_element(:name, "submit").click
    @driver.find_element(:link, "itemmarket.mail@gmai...").click

    element = @driver.find_element(:partial_link_text, "verify_account")
    href = element.attribute("href")
    @driver.get(href)

    element = @driver.find_element :id => "table_new"
    assert(element.text.include?("account is now activated"), "account was not activated")
  end

  def test_reset_password_scenario
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

    sleep 35 #Seconds to wait for email
    @driver.find_element(:name, "submit").click
    @driver.find_element(:link, "itemmarket.mail@gmai...").click

    element = @driver.find_element(:partial_link_text, "verify_account")
    href = element.attribute("href")
    @driver.get(href)

    @driver.get(@base_url + "/")
    @driver.find_element(:link, "Login").click
    @driver.find_element(:link, "Forgot Password").click
    @driver.find_element(:name, "email").clear
    @driver.find_element(:name, "email").send_keys @random_email
    @driver.find_element(:css, "td > input[type=\"submit\"]").click

    @driver.get("http://trash-mail.com/index.php")
    @driver.find_element(:name, "mail").click
    @driver.find_element(:name, "mail").clear
    @driver.find_element(:name, "mail").send_keys @username
    @driver.find_element(:name, "submit").click

    sleep 35
    @driver.find_element(:name, "submit").click
    @driver.find_element(:xpath, "(//a[contains(text(),'itemmarket.mail@gmai...')])[2]").click

    element = @driver.find_element(:partial_link_text, "reset_password")
    href = element.attribute("href")
    @driver.get(href)

    @driver.find_element(:xpath, "(//input[@name='password'])[2]").clear
    @driver.find_element(:xpath, "(//input[@name='password'])[2]").send_keys "pw123NEW"
    @driver.find_element(:name, "password_conf").clear
    @driver.find_element(:name, "password_conf").send_keys "pw123NEW"
    @driver.find_element(:css, "td > input[type=\"submit\"]").click

    element = @driver.find_element :name => "username"
    element.send_keys @username
    element = @driver.find_element :name => "password"
    element.send_keys "pw123NEW"
    element.submit

    assert_equal(@driver.current_url, "http://localhost:4567/")
    element = @driver.find_element :css => "h1"
    assert(element.text.include?("Welcome "+@username), "login was not successfull!")
    assert_equal(@driver.current_url, "http://localhost:4567/")
    assert_equal(@driver.title,"item|market")

  end


end