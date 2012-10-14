class Main < Sinatra::Application

  get "/" do
    if session[:name]
      #if logged in redirect to main
      haml :main, :locals => {:time => Time.now,
                              :users => Marketplace::User.all,
                              :current_user => Marketplace::User.by_name(session[:name])}
    else
      #if not redirect to mainguest
      haml :mainguest, :locals => { :time => Time.now,
                                    :users => Marketplace::User.all}
    end
  end
end
