class ItemActivate < Sinatra::Application

  # Switches the active attribute of item with given id
  post "/item/:id/activate" do

    current_item = Marketplace::Item.by_id(params[:id].to_i)
    current_user = Marketplace::User.by_name(session[:name])


    if  current_user == current_item.owner
        current_item.active = !current_item.active
        session[:message] = "Item is now #{current_item.active}"
        redirect "/item/#{current_item.id}"
    else
      session[:message] = "You are not the owner of this item"
      redirect "/item/#{current_item.id}"
    end

  end

end