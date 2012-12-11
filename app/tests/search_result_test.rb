require "test/unit"
require 'rubygems'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'


require '../../app/models/marketplace/entity.rb'
require '../../app/models/marketplace/user.rb'
require '../../app/models/marketplace/activity.rb'
require '../../app/models/marketplace/user.rb'
require '../../app/models/marketplace/item.rb'
require '../../app/models/marketplace/buy_order.rb'
require '../../app/models/marketplace/search_result.rb'
require '../../app/models/marketplace/database.rb'
require '../../app/helper/mailer.rb'
require '../../app/helper/validator.rb'
require '../../app/helper/checker.rb'
require '../../app/helper/image_uploader.rb'

class Search_Result_Test  < Test::Unit::TestCase
  database = Marketplace::Database.instance
  def test_searching_functions
  daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
  joel = Marketplace::User.create('Joel','test','joel.guggisberg@students.unibe.ch')
  lukas = Marketplace::User.create('Lukas','lol','lukas.v.rotz@gmail.com')

  item1 = Marketplace::Item.create('Table', "No Description", 100, 20, daniel)
  item2 = Marketplace::Item.create('Inception, Dvd', "No Description", 10, 30, joel)
  item3 = Marketplace::Item.create('Bed', "No Description", 50, 2, lukas)

  item1.active = true
  item2.active = true
  item3.active = false

  search_result = Marketplace::SearchResult.create("Table")
  search_result.get
  found_items = search_result.found_items
  #only one table should be found
  assert(found_items.size==1)
  assert(found_items[0].name=="Table")


  search_result = Marketplace::SearchResult.create("Tab")
  search_result.get
  found_items = search_result.found_items
  #only one table should be found, even if th query is incomplete
  assert(found_items.size==1)
  assert(found_items[0].name=="Table")


  item1.active = false

  search_result = Marketplace::SearchResult.create("Table")
  search_result.get
  found_items = search_result.found_items

  #since the Table is not active, nothing should be found
  assert(found_items.size==0)


 end

end