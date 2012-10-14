class User < Sinatra::Application

  get "/user/:name" do

    username = params[:name]
    message = session[:message]
    session[:message] = nil

    if username == session[:name]
      haml :user_profile_own, :locals => {  :user => Marketplace::User.by_name(username),
                                            :info => message}
    else
      haml :user_profile, :locals => {  :user => Marketplace::User.by_name(username),
                                        :info => message}
    end

  end

end