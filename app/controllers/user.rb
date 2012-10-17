class User < Sinatra::Application

  get "/user/:name" do

    username = params[:name]
    message = session[:message]
    session[:message] = nil
    user = Marketplace::User.by_name(username)

    if username == session[:name]
      haml :user_profile_own, :locals => {  :user => user,
                                            :info => message}
    else
      haml :user_profile, :locals => {  :user => user,
                                        :current_user => Marketplace::User.by_name(session[:name]),
                                        :info => message}
    end

  end

end