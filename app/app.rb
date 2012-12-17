require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'
require 'tlsmail'
require 'require_relative'
require 'amatch'


require_relative 'models/marketplace/entity.rb'
require_relative 'models/marketplace/activity.rb'
require_relative 'models/marketplace/user.rb'
require_relative 'models/marketplace/item.rb'
require_relative 'models/marketplace/buy_order.rb'
require_relative 'models/marketplace/search_result.rb'
require_relative 'models/marketplace/database.rb'
require_relative 'models/marketplace/category.rb'

require_relative 'helper/mailer.rb'
require_relative 'helper/validator.rb'
require_relative 'helper/checker.rb'
require_relative 'helper/image_uploader.rb'
require_relative 'helper/categorizer.rb'


require_relative 'controllers/main.rb'
require_relative 'controllers/login.rb'
require_relative 'controllers/reset_password'
require_relative 'controllers/register.rb'
require_relative 'controllers/settings.rb'
require_relative 'controllers/user.rb'
require_relative 'controllers/item.rb'
require_relative 'controllers/item_edit.rb'
require_relative 'controllers/item_activate.rb'
require_relative 'controllers/item_buy.rb'
require_relative 'controllers/item_create.rb'
require_relative 'controllers/item_comments.rb'
require_relative 'controllers/item_merge.rb'
require_relative 'controllers/search.rb'
require_relative 'controllers/delete_account.rb'
require_relative 'controllers/deactivate_account.rb'
require_relative 'controllers/buy.rb'
require_relative 'controllers/buy_confirm.rb'
require_relative 'controllers/verify'
require_relative 'controllers/buy_order_create.rb'
require_relative 'controllers/buy_order_delete.rb'
require_relative 'controllers/user_follow.rb'
require_relative 'controllers/item_follow.rb'
require_relative 'controllers/activity_log.rb'
require_relative 'controllers/paradise.rb'


class App < Sinatra::Base

  use Login
  use Register
  use ResetPassword
  use Verify
  use Main
  use User
  use Item
  use DeleteAccount
  use DeactivateAccount
  use ItemEdit
  use ItemActivate
  use ItemBuy
  use ItemCreate
  use ItemComments
  use ItemMerge
  use Settings
  use Buy
  use BuyConfirm
  use BuyOrderCreate
  use BuyOrderDelete
  use ActivityLog
  use UserFollow
  use ItemFollow
  use Paradise



  enable :sessions

  set :show_exceptions, true
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public")}



  configure :development do

    # Create some users
    daniel = Marketplace::User.create('Daniel','hallo','test@testmail1.com')
    joel = Marketplace::User.create('Joel','test','joel.guggisberg@students.unibe.ch')
    lukas = Marketplace::User.create('Lukas','lol','lukas.v.rotz@gmail.com')
    oliver = Marketplace::User.create('Oliver','aha','test@testmail3.com')
    rene = Marketplace::User.create('Rene','wtt','sudojudo@eml.cc')
    urs = Marketplace::User.create('Urs','123','UrsZysset@gmail.com')
    ese = Marketplace::User.create('ese','ese','ese@trash-mail.com')

    # Give them some money
    daniel.add_credits(2000)
    joel.add_credits(400)
    lukas.add_credits(400)
    oliver.add_credits(400)
    rene.add_credits(4000)
    urs.add_credits(100000)
    ese.add_credits(1000)

    # Verify users
    urs.verify
    daniel.verify
    joel.verify
    lukas.verify
    rene.verify
    ese.verify
    oliver.verify

    # Create some items
    item1 = Marketplace::Item.create('Table', "No Description", 100, 20, daniel)
    item2 = Marketplace::Item.create('Inception, Dvd', "No Description", 10, 30, joel)
    item3 = Marketplace::Item.create('Bed', "No Description", 50, 2, lukas)
    item4 = Marketplace::Item.create('Tolkien, Lord of the Rings 1, Book', "No Description", 20, 1, oliver)
    item5 = Marketplace::Item.create('Shoes', "No Description", 80, 7, rene)
    item6 = Marketplace::Item.create('Trousers', "No Description", 60, 99, urs)
    item7 = Marketplace::Item.create('Bed', "No Description", 60, 4, joel)
    item8 = Marketplace::Item.create('Bed', "No Description", 30, 5, oliver)
    item9 = Marketplace::Item.create('Shoes', "No Description", 20, 4, oliver)
    item10 = Marketplace::Item.create('Fridge', "No Description", 210, 2, oliver)
    item11 = Marketplace::Item.create('Fridge', "No Description", 300, 5, lukas)
    item12 = Marketplace::Item.create('Fridge', "No Description", 279, 10, rene)
    item13 = Marketplace::Item.create('Red Fridge', "No Description", 400, 10, joel)
    item14 = Marketplace::Item.create('Spicy Chily', "No Description", 35, 15, ese)
    item15 = Marketplace::Item.create('Apple', "No Description", 3, 15, ese)
    item16 = Marketplace::Item.create('Apple', "No Description", 3, 10, ese)
    item17 = Marketplace::Item.create('Can of Beans', "No Description", 3, 8, ese)
    item18 = Marketplace::Item.create('SuperMan Costume', "No Description", 3, 60, oliver)
    item19 = Marketplace::Item.create('Bravo  Hits 5, CD', "No Description", 2, 1, ese)
    item20 = Marketplace::Item.create('The Matrix, DVD', "No Description", 20, 3, joel)
    item21 = Marketplace::Item.create('Golden Rolex', "No Description", 1000, 1, urs)
    item22 = Marketplace::Item.create('Vestax VCI 400 Dj Controller', "No Description", 400, 1, lukas)
    item23 = Marketplace::Item.create('THE one and only Magic Ring', "No Description", 30000, 1, rene)
    item24 = Marketplace::Item.create('Cool Runnings, DVD', "No Description", 40, 4, ese)
    item25 = Marketplace::Item.create('Bag of Dubplates', "No Description", 10, 7, rene)
    item26 = Marketplace::Item.create('AK 47', "No Description", 1000, 3, ese)
    item27 = Marketplace::Item.create('Trousers', "sdfdsf", 60, 40, urs)

    # Set the items state
    item1.active = true
    item2.active = true
    item3.active = true
    item4.active = true
    item5.active = true
    item6.active = true
    item7.active = true
    item8.active = true
    item9.active = true
    item10.active = true
    item11.active = true
    item12.active = true
    item13.active = true
    item14.active = true
    item15.active = true
    item16.active = true
    item17.active = true
    item18.active = true
    item19.active = true
    item20.active = true
    item21.active = true
    item22.active = true
    item23.active = true
    item24.active = true
    item25.active = true
    item26.active = true
    item27.active = true

  end

end

# Now, run it
App.run!