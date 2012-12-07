require "test/unit"
require 'rubygems'
#require 'sinatra'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'


require '../../../app/models/marketplace/entity.rb'
require '../../../app/models/marketplace/user.rb'
require '../../../app/models/marketplace/activity.rb'
require '../../../app/models/marketplace/user.rb'
require '../../../app/models/marketplace/item.rb'
require '../../../app/models/marketplace/buy_order.rb'
require '../../../app/models/marketplace/search_result.rb'
require '../../../app/models/marketplace/database.rb'
require '../../../app/helper/mailer.rb'
require '../../../app/helper/validator.rb'
require '../../../app/helper/checker.rb'
require '../../../app/helper/image_uploader.rb'




class Database_Tests < Test::Unit::TestCase
  def test_user_functions
    database = Marketplace::Database.instance
    user = Marketplace::User.create('John','pW123','test@testmail1.com')
    database.add_user(user)
    assert(database.all_users.include?(user),"User not included")
    assert(database.user_by_name('John')==user,"Username Wrong")

    user2 = database.user_by_email('test@testmail1.com')
    assert(user2.name=="John")

     end

  def test_item_functions
    database = Marketplace::Database.instance

    #todo
  end

  def test_item_category_functions
    database = Marketplace::Database.instance

    #todo
  end

  def test_hashmaps



  end

end