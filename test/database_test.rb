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
    user = Marketplace::User.create('John','pW123','test@testmail1.com')
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

  def test_hashmaps

    database = Marketplace::Database.instance
    hash = "asjhakfad12lj3lkehkf2342h3hk4j"
    user = Marketplace::User.create('John','pW123','test@testmail1.com')
    timestamp = Time.new

    database.add_to_ver_hashmap(hash,user,timestamp)
    database.add_to_rp_hashmap(hash,user,timestamp)

    assert_equal(database.get_user_from_ver_hashmap_by(hash),user, "User saved incorrectly")
    assert_equal(database.get_user_from_rp_hashmap_by(hash),user, "User saved incorrectly")

    assert(timestamp = database.get_timestamp_from_ver_hashmap_by(hash), "Timestamp saved incorrectly")
    assert(timestamp = database.get_timestamp_from_rp_hashmap_by(hash), "Timestamp saved incorrectly")

    assert(database.hash_exists_in_ver_hashmap?("asjhakfad12lj3lkehkf2342h3hk4j"), "Hash should exist")
    assert(database.hash_exists_in_rp_hashmap?("asjhakfad12lj3lkehkf2342h3hk4j"), "Hash should exist")

    database.delete_entry_from_ver_hashmap(hash)
    database.delete_entry_from_rp_hashmap(hash)

    assert(!(database.hash_exists_in_ver_hashmap?("asjhakfad12lj3lkehkf2342h3hk4j")), "Hash shouldnt exist anymore")
    assert(!(database.hash_exists_in_rp_hashmap?("asjhakfad12lj3lkehkf2342h3hk4j")), "Hash shouldnt exist anymore")

    timestamp2 = Time.new-86401
    database.add_to_rp_hashmap(hash,user,timestamp2)

    database.delete_24h_old_entries_from_rp_hashmap
    assert(!(database.hash_exists_in_rp_hashmap?("asjhakfad12lj3lkehkf2342h3hk4j")), "Hash shouldnt exist anymore")


  end

end