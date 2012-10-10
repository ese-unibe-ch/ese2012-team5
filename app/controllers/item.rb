require 'rubygems'
require 'sinatra'
require 'tilt/haml'

require '../app/models/marketplace/user'
require '../app/models/marketplace/item'
class Item < Sinatra::Application
  # To change this template use File | Settings | File Templates.
    get "/items"  do


      items= Marketplace::Item.all
      actualUser = Marketplace::User.by_name(session[:name])
      haml :item   , :locals => { :items => items, :user => actualUser}

    end

    post "/items"  do


      items= Marketplace::Item.all

      itemToBuy = Marketplace::Item.by_id(Integer(params[:Item]))

      actualUser.buy(itemToBuy)

      haml :item   , :locals => { :items => items, user => actualUser}

    end



end