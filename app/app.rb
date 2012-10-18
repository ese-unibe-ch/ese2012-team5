require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'tilt/haml'

require 'models/marketplace/user.rb'
require 'models/marketplace/item.rb'

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
    item1.active = true
    item2.active = true
    item3.active = true
    item4.active = true
    item5.active = true
    item6.active = true
    Marketplace::Database.add_user(daniel)
    Marketplace::Database.add_user(joel)
    Marketplace::Database.add_user(lukas)
    Marketplace::Database.add_user(oliver)
    Marketplace::Database.add_user(rene)
    Marketplace::Database.add_user(urs)
  end

end

# Now, run it
App.run!