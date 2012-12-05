class UserFollow < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post "/user/:name/follow" do
    current_user = @database.user_by_name(session[:name])
    user = @database.user_by_name(params[:name])

    current_user.add_subscription(user)

    session[:message] = "~note~You are now following #{user.name}."
    redirect "user/#{current_user.name}"
  end

  post "/user/:name/unfollow" do
    current_user = @database.user_by_name(session[:name])
    user = @database.user_by_name(params[:name])

    current_user.delete_subscription(user)

    session[:message] = "~note~You don't follow #{user.name} anymore!"
    redirect "user/#{current_user.name}"
  end

end