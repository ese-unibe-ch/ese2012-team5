class ItemActivate < Sinatra::Application
  before do
    @database = Marketplace::Database.instance
  end

  # Switches the active attribute of item with given id
  post "/item/:id/activate" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])


    if current_user == current_item.owner
      switchActive(current_item)
      session[:message] = "Item is now #{current_item.active}"
      redirect "/item/#{current_item.id}"
    else
      session[:message] = "You are not the owner of this ite!"
      redirect "/item/#{current_item.id}"
    end

  end

  def switchActive(current_item)
    current_item.active = !current_item.active
  end

end