class ItemBuy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # The user with current session buys the item with given id
  # If no session exists, you will be redirected to '/login'
  # If user doesn't own enough credits or item is not active
  # or user is already owner, the transaction will fail
  post "/item/:id/buy" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])
    quantity = params[:quantity].to_i


    # Check for guests playing around
    if !current_user
      session[:message] = "error ~ Log in to buy items"
      redirect '/login'
    end

    # Checks if quantity is wrong
    if quantity <= 0 or quantity > current_item.quantity
      session[:message] = "error ~ Quantity #{quantity} not valid!"
      redirect "/item/#{current_item.id}"
    end

    # Check if user isn't able to buy item
    if !current_user.can_buy_item?(current_item, quantity)
      session[:message] = "error ~ You can't buy this item! Not active or not enough credits"
      redirect "/item/#{current_item.id}"
    end


    #
    # Start with buy-algorithm
    #

    # If necessary split up the item otherwise take the whole item
    #if quantity < current_item.quantity
    #  item_to_sell = current_item.split(quantity)
    #else
    #  item_to_sell = current_item
    #end


    # Check if the buyer already owns a similar item, do we need to merge these items?
    need_merge = false
    current_user.items.each{ |item| need_merge = true if item.mergeable?(current_item)}


    # Let the buyer buy the item
    current_item = current_user.buy(current_item, quantity)


    if need_merge
      haml :item_merge, :locals => { :new_item => current_item}
    else
      session[:message] = "message ~ You bought #{current_item.name}(Amount:#{quantity})"
      redirect "/user/#{current_user.name}"
    end

  end

end