require 'test/unit'
require 'rubygems'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'require_relative'

require_relative '../../app/models/marketplace/entity.rb'
require_relative '../../app/models/marketplace/activity.rb'
require_relative '../../app/models/marketplace/user.rb'
require_relative '../../app/models/marketplace/item.rb'
require_relative '../../app/models/marketplace/database.rb'
require_relative '../../app/models/marketplace/category.rb'

class CategoryTest < Test::Unit::TestCase

  def setup
    @database = Marketplace::Database.instance

    @daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
    @joel = Marketplace::User.create('Joel','test','joel.guggisberg@students.unibe.ch')
    @lukas = Marketplace::User.create('Lukas','lol','lukas.v.rotz@gmail.com')

    @daniel.verify
    @joel.verify
    @lukas.verify

    @bed1 = Marketplace::Item.create('Bed', "cozy", 10, 30, @joel)
    @bed2 = Marketplace::Item.create('Bed', "cozy", 11, 6, @daniel)
    @bed3 = Marketplace::Item.create('Bed', "not cozy", 5, 2, @lukas)
    @bed4 = Marketplace::Item.create('Bed of Dr. Hyde', "creepy", 11, 6, @daniel)

    @bed1.activate
    @bed2.activate
    @bed3.activate
    @bed4.activate
  end

  def teardown
    Marketplace::Database.reset_database
  end

  def test_category_create
    bed_category = Marketplace::Category.create(@bed1)

    assert(!bed_category.has_multiple_owners, "should only have one owner")
    assert(!bed_category.has_multiple_items, "should only have one item")

    bed_category.add(@bed2)
    assert(bed_category.owner_count == 2,"item not added")

    assert(bed_category.item_count == 2,"item not added")
    bed_category.add(@bed3)
    assert(bed_category.owner_count == 3,"item not added")
    assert(bed_category.has_multiple_owners, "should have multiple owners")
    assert(bed_category.has_multiple_items, "should have multiple items")
    assert(bed_category.min_price == 5, "min price is not right")
    assert(bed_category.quantity == 38, "quantity is not right")


    assert_raise NotImplementedError do
      bed_category.add(@bed4)
    end

    assert(bed_category.owner_count == 3,"item added, but shouldnt because wrong name")

  end

end