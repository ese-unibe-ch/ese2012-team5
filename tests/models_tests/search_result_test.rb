require 'test/unit'
require 'rubygems'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'
require 'amatch'

require_relative '../../app/models/marketplace/entity.rb'
require_relative '../../app/models/marketplace/activity.rb'
require_relative '../../app/models/marketplace/user.rb'
require_relative '../../app/models/marketplace/item.rb'
require_relative '../../app/models/marketplace/search_result.rb'
require_relative '../../app/models/marketplace/database.rb'


class Search_Result_Test < Test::Unit::TestCase

  def setup
    @database = Marketplace::Database.instance

    @daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
    @joel = Marketplace::User.create('Joel','test','joel.guggisberg@students.unibe.ch')
    @lukas = Marketplace::User.create('Lukas','lol','lukas.v.rotz@gmail.com')

    @daniel.verify
    @joel.verify
    @lukas.verify

    @table = Marketplace::Item.create('Table', "No Description", 100, 20, @daniel)
    @dvd = Marketplace::Item.create('Inception, Dvd', "No me", 10, 30, @joel)
    @bed1 = Marketplace::Item.create('Bed', "No Description", 44, 6, @lukas)
    @bed2 = Marketplace::Item.create('Bed', "find me", 50, 2, @lukas)

    @table.activate
    @dvd.activate
    @bed1.activate
    @bed2.activate
  end

  def teardown
    Marketplace::Database.reset_database
  end

  def test_find_both_beds_with_query_bed
    search_result = Marketplace::SearchResult.create("Bed")
    search_result.find(@database.all_active_items)
    found_items = search_result.found_items

    assert_equal(found_items.length, 2, "resultsize was not 2!")
    assert_equal(found_items, [@bed1, @bed2], "could not just find both beds!")
  end

  def test_find_table_with_query_tab
    search_result = Marketplace::SearchResult.create("Tab")
    search_result.find(@database.all_active_items)
    found_items = search_result.found_items

    assert_equal(found_items.size, 1, "resultsize was not 1!")
    assert_equal(found_items, [@table], "could not just find table!")
  end

  def test_find_nothing_with_query_tabel
    search_result = Marketplace::SearchResult.create("Tabel")
    search_result.find(@database.all_active_items)
    found_items = search_result.found_items
    closest_string = search_result.closest_string

    assert_equal(found_items.size, 0, "resultsize was not empty!")
    assert_equal(found_items, [], "result was not empty!")
    assert_equal(closest_string, "Table", "suggestion not found")
  end

  def test_find_nothing_with_query_table
    search_result = Marketplace::SearchResult.create("Table")
    search_result.find(@database.all_active_items.select{ |item| item != @table })
    found_items = search_result.found_items

    assert_equal(found_items.size, 0, "resultsize was not empty!")
    assert_equal(found_items, [], "result was not empty!")
  end

  def test_find_suggestion_with_query_tabel
    search_result = Marketplace::SearchResult.create("Tabel")
    search_result.find(@database.all_active_items)
    found_items = search_result.found_items
    closest_string = search_result.closest_string

    assert_equal(found_items.size, 0, "resultsize was not empty!")
    assert_equal(found_items, [], "result was not empty!")
    assert_equal(closest_string, "Table", "suggestion not found")
  end

  def test_find_bed_and_dvd_with_query_me
    search_result = Marketplace::SearchResult.create("me")
    search_result.find(@database.all_active_items)
    found_items = search_result.found_items

    assert_equal(found_items.size, 2, "resultsize was not 2!")
    assert_equal(found_items, [@dvd, @bed2], "could not just find bed2 and dvd!")
  end

  def test_find_bed_with_query_find_me
    search_result = Marketplace::SearchResult.create("find_me")
    search_result.find(@database.all_active_items)
    found_items = search_result.found_items

    assert_equal(found_items.size, 1, "resultsize was not 1!")
    assert_equal(found_items, [@bed2], "could not just find bed2!")
  end

end