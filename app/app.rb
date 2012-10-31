require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'tilt/haml'
require 'webget_ruby_secure_random'

require 'models/marketplace/user.rb'
require 'models/marketplace/item.rb'
require 'models/marketplace/database.rb'
require 'models/helper/mailer.rb'
require 'models/helper/validator.rb'
require 'models/helper/checker.rb'

require 'controllers/main.rb'
require 'controllers/login.rb'
require 'controllers/reset_password'
require 'controllers/register.rb'
require 'controllers/settings.rb'
require 'controllers/user.rb'
require 'controllers/item.rb'
require 'controllers/item_edit.rb'
require 'controllers/item_activate.rb'
require 'controllers/item_buy.rb'
require 'controllers/item_create.rb'
require 'controllers/item_merge.rb'
require 'controllers/delete_account.rb'
require 'controllers/buy.rb'
require 'controllers/buy_confirm.rb'
require 'controllers/verify'


class App < Sinatra::Base

  use Login
  use DeleteAccount
  use Register
  use Main
  use User
  use Item
  use ItemEdit
  use ItemActivate
  use ItemBuy
  use ItemCreate
  use Settings
  use ItemMerge
  use Buy
  use BuyConfirm
  use ResetPassword
  use Verify


  enable :sessions

  set :public_folder, 'app/public'
  set :show_exceptions, false
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public")}

  configure :development do
    database = Marketplace::Database.instance

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
    urs.add_credits(1000)
    ese.add_credits(1000)

    # Verify users
    urs.verify
    daniel.verify
    joel.verify
    lukas.verify
    rene.verify
    ese.verify

    # Create some items
    item1 = Marketplace::Item.create('Table', 100, 20, daniel)
    item2 = Marketplace::Item.create('Dvd', 10, 30, joel)
    item3 = Marketplace::Item.create('Bed', 50, 2, lukas)
    item4 = Marketplace::Item.create('Book', 20, 1, oliver)
    item5 = Marketplace::Item.create('Shoes', 80, 7, rene)
    item6 = Marketplace::Item.create('Trousers', 60, 99, urs)
    item7 = Marketplace::Item.create('Bed', 60, 4, joel)
    item8 = Marketplace::Item.create('Bed', 30, 5, oliver)
    item9 = Marketplace::Item.create('Shoes', 20, 4, oliver)
    item10 = Marketplace::Item.create('Fridge', 210, 2, oliver)
    item11 = Marketplace::Item.create('Fridge', 300, 5, lukas)
    item12 = Marketplace::Item.create('Fridge', 279, 10, rene)
    item13 = Marketplace::Item.create('Red Fridge', 400, 10, joel)
    item14 = Marketplace::Item.create('Spicy Chily', 35, 15, ese)
    item15 = Marketplace::Item.create('Can of Beans', 3, 60, ese)

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

    # Add users and items to database
    database.add_item(item1)
    database.add_item(item2)
    database.add_item(item3)
    database.add_item(item4)
    database.add_item(item5)
    database.add_item(item6)
    database.add_item(item7)
    database.add_item(item8)
    database.add_item(item9)
    database.add_item(item10)
    database.add_item(item11)
    database.add_item(item12)
    database.add_item(item13)
    database.add_item(item14)
    database.add_item(item15)

    database.add_user(daniel)
    database.add_user(joel)
    database.add_user(lukas)
    database.add_user(oliver)
    database.add_user(rene)
    database.add_user(urs)
    database.add_user(ese)

  end

end

# Now, run it
App.run!