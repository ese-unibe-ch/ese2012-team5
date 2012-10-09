

class User < Sinatra::Application

  get "/user/:name" do
    username = params[:name]

    if username == session[:name]
      #redirect to your profile
      haml :own_user, :locals => {:time => Time.now,
                                  :user => Marketplace::User.by_name(username) }
    else
      # redirect to any others profile
      haml :user, :locals => {  :time => Time.now,
                                :user => Marketplace::User.by_name(username) }
    end
  end
end