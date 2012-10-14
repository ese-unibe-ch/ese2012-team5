class Item < Sinatra::Application

  # Displays the profile of the item with given id
  get "/item/:id" do

    current_item = Marketplace::Item.by_id(params[:id].to_i)
    current_user = Marketplace::User.by_name(session[:name])


    message = session[:message]
    session[:message] = nil


    if current_user == current_item.owner
      haml :item_profile_own, :locals => {:item => current_item,
                                          :info => message}
    else

      # Decide if user is able to buy the item
      if current_user
        canBuy  = current_user.credits >= current_item.price
      else
        canBuy = false
      end

      haml :item_profile, :locals => {:item => current_item,
                                      :info => message,
                                      :canBuy => canBuy}
    end
  end


end