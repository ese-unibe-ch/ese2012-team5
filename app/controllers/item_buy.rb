class ItemBuy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  post "/item/:id/place_bid" do
    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])
    bid = params[:bid].to_i

    # Check for guests playing around
    if !current_user
      session[:message] = "error ~ Log in to bid for items"
      redirect '/login'
    end

    if !current_item.auction.can_place_bid?(bid)
      session[:message] = "error ~ Cannot place this bid, try to bid more."
      redirect "/item/#{current_item.id}"
    end

    if !current_user.enough_credits(bid)
      session[:message] = "error ~ You don't have enough credits."
      redirect "/item/#{current_item.id}"
    end

    if !current_item.auction.place_bid(bid, current_user)
      session[:message] = "error ~ Cannot place this bid. You can only increase your maximal price."
      redirect "/item/#{current_item.id}"
    end

    if current_item.auction.current_winner != current_user
      session[:message] = "You have been overbidden by user #{current_item.auction.current_winner.name}. Place a higher bid."
    else
      session[:message] = "message ~ Successfully placed bid."
    end
    redirect "/item/#{current_item.id}"
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
    if quantity < current_item.quantity
      item_to_sell = current_item.split(quantity)
    else
      item_to_sell = current_item
    end


    # Check if the buyer already owns a similar item, do we need to merge these items?
    need_merge = false
    current_user.items.each{ |item| need_merge = true if item.mergeable?(item_to_sell)}


    # Let the buyer buy the item
    current_user.buy(item_to_sell)


    if need_merge
      haml :item_merge, :locals => { :new_item => item_to_sell}
    else
      session[:message] = "message ~ You bought #{item_to_sell.name} (Amount: #{item_to_sell.quantity})"
      redirect "/user/#{current_user.name}"
    end

  end

end