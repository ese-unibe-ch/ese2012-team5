class User < Sinatra::Application

  get "/user/:name" do
    username = params[:name]

    if username == session[:name]
      haml :user_profile_own, :locals => {:time => Time.now,
                                          :user => Marketplace::User.by_name(username) }
    else
      haml :user_profile, :locals => {  :time => Time.now,
                                        :user => Marketplace::User.by_name(username) }
    end
  end
end