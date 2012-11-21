class ItemActivate < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post "/item/:id/activate" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])

    if current_user == current_item.owner
      quantity_before = current_item.quantity
      current_item.switch_active # Will toggle Event(for buy_orders) when item is activated

      if current_item.active
        session[:message] = "message ~ Item is now active."
      else
        session[:message] = "message ~ Item is now inactive."
      end

      # In case of buy_order the item is already sold or if its quantity is higher than one, one piece maybe sold
      session[:message] << "</br>And Item was already sold!" if current_item.owner != current_user
      session[:message] << "</br>And one piece of Item was already sold!" if current_item.quantity != quantity_before
      redirect "/user/#{current_user.name}"
    else
      session[:message] = "error ~ You are not the owner of this item!"
      redirect "/item/#{current_item.id}"
    end

  end

end