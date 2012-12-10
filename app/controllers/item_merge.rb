class ItemMerge < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
  end


  get "/item/:id/merge" do
    redirect '/login' unless @current_user
    current_item = @database.item_by_id(params[:id].to_i)
    other_item = @database.item_by_id(params[:other_item_id].to_i)

    message = session[:message]
    session[:message] = nil
    haml :item_merge, :locals => {:user => @current_user,
                                  :info => message,
                                  :item1 => current_item,
                                  :item2 => other_item }
  end

  post "/item/:id/merge" do
    current_item = @database.item_by_id(params[:id].to_i)
    other_item = @database.item_by_id(params[:other_item_id].to_i)

    current_item.merge(other_item)

    session[:message] = "~note~merge was successful!"
    redirect "/user/#{@current_user.name}"
  end

end