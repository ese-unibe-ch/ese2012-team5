class UserFollow < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
  end

  # Takes care of adding another user to a users subscriptions.
  post '/user/:name/follow' do
    user = @database.user_by_name(params[:name])

    @current_user.add_subscription(user)

    session[:message] = "~note~You are now following #{user.name}."
    redirect "user/#{@current_user.name}"
  end

  # Takes care of removing another user from a users subscriptions.
  post '/user/:name/unfollow' do
    user = @database.user_by_name(params[:name])

    @current_user.delete_subscription(user)

    session[:message] = "~note~You don't follow #{user.name} anymore!"
    redirect "user/#{@current_user.name}"
  end

end