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
        session[:message] = "~note~item is now active."
        if current_item.get_status_changed(current_item.description, current_item.price)
          time_now = Time.new
          current_item.add_description(time_now, current_item.description, current_item.price)
        end
      else
        session[:message] = "~note~item is now inactive."
      end

      # In case of buy_order the item is already sold or if its quantity is higher than one, one piece maybe sold
      session[:message] += "~note~item was already sold!" if current_item.owner != current_user
      session[:message] += "~note~one piece of Item was already sold!" if current_item.quantity != quantity_before

      redirect "/user/#{current_user.name}"
    else
      session[:message] = "~error~you are not the owner of this item!"
      redirect "/item/#{current_item.id}"
    end

  end

end