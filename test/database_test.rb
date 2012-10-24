require 'test/unit'
require 'rubygems'
require 'bcrypt'
require '../app/models/marketplace/item.rb'
require '../app/models/marketplace/user.rb'
require '../app/models/marketplace/database.rb'

# syntax for inheritance
class DatabaseTest < Test::Unit::TestCase

  def test_user_functions
    database = Marketplace::Database.instance
    user = Marketplace::User.create('John','pW123')
    database.add_user(user)
    assert(database.all_users.include?(user),"User not included")
    assert(database.user_by_name('John')==user,"Username Wrong")

    database.delete_user(user)
    assert(!database.all_users.include?(user),"User not deleted")
  end

  def test_item_functions
    database = Marketplace::Database.instance

    #todo
  end

  def test_item_category_functions
    database = Marketplace::Database.instance

    #todo
  end

end