require 'haml'
require 'app/models/marketplace/user'
require 'app/controllers/item'

class User < Sinatra::Application

  get "/user" do
    #redirect user to the userpage
    haml :user, :locals => {:time => Time.now,
                            :users => Client::User.all,
                            :current_name => session[:name]}
  end
end