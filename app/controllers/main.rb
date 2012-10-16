class Main < Sinatra::Application

  get "/" do
    message = session[:message]
    session[:message] = nil
    if session[:name]
      #if logged in redirect to main
      haml :main, :locals => {:time => Time.now,
                              :users => Marketplace::User.all,
                              :current_user => Marketplace::User.by_name(session[:name])}
    else
      #if not redirect to mainguest
      haml :mainguest, :locals => { :time => Time.now,
                                    :users => Marketplace::User.all,
                                    :info => message }
    end
  end
end
