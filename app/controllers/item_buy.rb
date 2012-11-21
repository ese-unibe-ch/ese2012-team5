class ItemBuy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post "/item/:id/buy" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])
    quantity = params[:quantity].to_i

    #TODO add helper here
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


    seller = current_item.owner
    bought_item = current_user.buy(current_item, quantity)

    session[:message] = "message ~ You bought #{bought_item.quantity}x #{bought_item.name} from #{seller.name})"
    redirect "/user/#{current_user.name}"
  end

end