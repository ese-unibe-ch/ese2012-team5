require 'rubygems'
require 'sinatra'
require 'tilt/haml'

require '../app/models/marketplace/user'
require '../app/models/marketplace/item'


class User < Sinatra::Application
  # To change this template use File | Settings | File Templates.
  get "/users" do

    #session[:name] = 'Daniel'


    actualUser = Marketplace::User.by_name(session[:name])


    haml :user, :locals => {:user => actualUser}

  end


  post "/users" do

    #session[:name] = params['Daniel']


    actualUser = Marketplace::User.by_name(session[:name])

    item = Marketplace::Item.by_id(Integer(:Item))


    if item.active
      item.deactivate
    else
      item.activate
    end


    haml :user, :locals => {:user => actualUser}

  end

end