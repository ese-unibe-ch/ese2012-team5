class Activities < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  post '/follow_user' do

    current_user = @database.user_by_name(session[:name])

    user = @database.user_by_name(params[:name])

    current_user.follow(user)

    redirect '/following'

  end

  post '/follow_item' do

    current_user = @database.user_by_name(session[:name])

    item = @database.item_by_id(params[:id])

    current_user.follow(item)

    redirect '/following'

  end

  post 'unfollow_user' do

    current_user = @database.user_by_name(session[:name])

    user = @database.user_by_name(params[:name])

    current_user.unfollow(user)

    redirect '/following'

  end

  post '/unfollow_item' do

    current_user = @database.user_by_name(session[:name])

    item = @database.item_by_id(params[:id])

    current_user.unfollow(item)

    redirect '/following'

  end

end