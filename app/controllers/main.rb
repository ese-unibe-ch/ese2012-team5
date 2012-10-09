require 'haml'
require 'app/models/marketplace/user'
require 'app/controllers/item'

class Main < Sinatra::Application
  get "/" do
    if session[:name]
      #if logged in redirect to main
      haml :main, :locals => {:time => Time.now,
                              :users => Client::User.all,
                              :current_name => session[:name]}
    else
      #if not redirect to mainguest
      haml :mainguest, :locals => {:time => Time.now,
                                   :users => Client::User.all}
    end
  end
end
