class ItemBuy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post "/item/:id/buy" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])
    quantity = params[:quantity].to_i


    session[:message] = ""
    session[:message] += Helper::Validator.validate_integer(quantity, "quantity", 0, current_item.quantity)
    session[:message] += "~error~you can't buy this item!</br>not active or not enough credits!" if !current_user.can_buy_item?(current_item, quantity)
    if session[:message] != ""
      redirect "/item/#{current_item.id}"
    end

    seller = current_item.owner
    bought_item = current_user.buy(current_item, quantity)

    session[:message] = "~note~you bought #{bought_item.quantity}x #{bought_item.name} from #{seller.name})"
    redirect "/user/#{current_user.name}"
  end

end