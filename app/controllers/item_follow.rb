class ItemFollow < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
  end


  post '/item/:id/follow' do
    current_item = @database.item_by_id(params[:id].to_i)

    @current_user.add_subscription(current_item)

    session[:message] = "~note~You are now following #{current_item.name}."
    redirect "user/#{@current_user.name}"
  end

  post '/item/:id/unfollow' do
    current_item = @database.item_by_id(params[:id].to_i)

    @current_user.delete_subscription(current_item)

    session[:message] = "~note~You don't follow #{current_item.name} anymore!"
    redirect "user/#{@current_user.name}"
  end

end