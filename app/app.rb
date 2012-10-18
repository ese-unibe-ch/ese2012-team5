require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'tilt/haml'

require 'models/marketplace/user.rb'
require 'models/marketplace/item.rb'
require 'models/marketplace/database.rb'

require 'controllers/main.rb'
require 'controllers/login.rb'
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


  enable :sessions

  set :public_folder, 'app/public'
  set :show_exceptions, false
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public")}

  configure :development do
    database = Marketplace::Database.instance
    daniel = Marketplace::User.create('Daniel','hallo')
    joel = Marketplace::User.create('Joel','test')
    lukas = Marketplace::User.create('Lukas','lol')
    oliver = Marketplace::User.create('Oliver','aha')
    rene = Marketplace::User.create('Rene','wtt')
    urs = Marketplace::User.create('Urs','123')
    item1 = Marketplace::Item.create('Table', 100, 20, daniel)
    item2 = Marketplace::Item.create('Dvd', 10, 30, joel)
    item3 = Marketplace::Item.create('Bed', 50, 2, lukas)
    item4 = Marketplace::Item.create('Book', 20, 1, oliver)
    item5 = Marketplace::Item.create('Shoes', 80, 7, rene)
    item6 = Marketplace::Item.create('Trousers', 60, 99, urs)
    item7 = Marketplace::Item.create('Bed', 60, 4, joel)
    item8 = Marketplace::Item.create('Bed', 30, 5, oliver)
    item9 = Marketplace::Item.create('Shoes', 20, 4, oliver)
    item1.active = true
    item2.active = true
    item3.active = true
    item4.active = true
    item5.active = true
    item6.active = true
    item7.active = true
    item8.active = true
    item9.active = true
    database.add_item(item1)
    database.add_item(item2)
    database.add_item(item3)
    database.add_item(item4)
    database.add_item(item5)
    database.add_item(item6)
    database.add_item(item7)
    database.add_item(item8)
    database.add_item(item9)
    database.add_user(daniel)
    database.add_user(joel)
    database.add_user(lukas)
    database.add_user(oliver)
    database.add_user(rene)
    database.add_user(urs)
  end

end

# Now, run it
App.run!