require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'tilt/haml'

require 'models/marketplace/user.rb'
require 'models/marketplace/item.rb'

require 'controllers/main.rb'
require 'controllers/authentication.rb'
require 'controllers/transaction.rb'
require 'controllers/settings.rb'
require 'controllers/user.rb'
require 'controllers/item.rb'

class App < Sinatra::Base

  use Authentication
  use Main
  use Transaction
  use User
  use Item
  use Settings

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
    item1 = Marketplace::Item.create('Table', 100, daniel)
    item2 = Marketplace::Item.create('Dvd', 10, joel)
    item3 = Marketplace::Item.create('Bed', 50, lukas)
    item4 = Marketplace::Item.create('Book', 20, oliver)
    item5 = Marketplace::Item.create('Shoes', 80, rene)
    item6 = Marketplace::Item.create('Trousers', 60, urs)
    item1.active = true
    item2.active = true
    item3.active = true
    item4.active = true
    item5.active = true
    item6.active = true
    daniel.save
    joel.save
    lukas.save
    oliver.save
    rene.save
    urs.save
    puts(Marketplace::User.all)
  end

end

# Now, run it
App.run!