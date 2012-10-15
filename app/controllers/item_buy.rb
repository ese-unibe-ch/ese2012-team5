class ItemBuy < Sinatra::Application

  # The user with current session buys the item with given id
  # If no session exists, you will be redirected to '/login'
  # If user doesn't own enough credits or item is not active
  # or user is already owner, the transaction will fail
  post "/item/:id/buy" do

    current_item = Marketplace::Item.by_id(params[:id].to_i)
    current_user = Marketplace::User.by_name(session[:name])


    if !current_user
      session[:message] = "Log in to buy items"
      redirect '/login'
    end

    if user_can_buy_item?(current_user, current_item)

      #this check if an Item with the same name already exists
      same_name_item=false
      current_user.items.each { |item| same_name_item = true if item.name == current_item.name }
      #buy after checkin is important for no false positive
      current_user.buy(current_item, params[:quantity].to_i)

      if same_name_item
        current_item=current_user.items.detect{|item| item.name == current_item.name}
        haml:merge_items, :locals => {:new_item => current_item}
      else
        session[:message] = "You bought #{current_item.name}"
        redirect "/user/#{current_user.name}"
      end
    else
      session[:message] = "You can't buy this item"
      redirect "/item/#{current_item.id}"
    end

  end

  def user_can_buy_item?(current_user, current_item)
    current_user.name != current_item.owner and current_item.price*params[:quantity].to_i <= current_user.credits and current_item.active
  end

end