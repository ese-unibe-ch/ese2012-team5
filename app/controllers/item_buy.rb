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

    # Store seller
    seller = current_item.owner

    # Let the buyer buy the item
    bought_item = current_user.buy(current_item, quantity)

    session[:message] = "message ~ You bought #{bought_item.name}(Amount:#{bought_item.quantity})"
    redirect "/user/#{current_user.name}"

  end

end