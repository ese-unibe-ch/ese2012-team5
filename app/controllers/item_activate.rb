class ItemActivate < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Switches the active attribute of item with given id
  post "/item/:id/activate" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])

    if current_user == current_item.owner
      current_item.switch_active
      if(current_item.active)
        session[:message] = "message ~ Item is now active."
      else
        session[:message] = "message ~ Item is now inactive."
      end
      if(current_item.owner != current_user)
        session[:message] = "message ~ Item was sold!."
      end

      redirect "/user/#{current_user.name}"
    else
      session[:message] = "error ~ You are not the owner of this item!"
      redirect "/item/#{current_item.id}"
    end

  end

end