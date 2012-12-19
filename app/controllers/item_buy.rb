class ItemBuy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Takes care of buy process of an item if bought via item view.
  # See also buy.rb controller for buy process via main and buy confirm view.
  post '/item/:id/buy' do
    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])
    quantity = params[:quantity].to_i

    session[:message] = ""
    session[:message] += Validator.validate_integer(quantity, "quantity", 1, current_item.quantity) # At least 1
    session[:message] += "~error~you don't have enough credits!" if !current_user.has_enough_credits?(current_item.price * quantity)
    session[:message] += "~error~the item is not for sale!" if !current_item.active
    if session[:message] != ""
      redirect "/item/#{current_item.id}"
    end

    seller = current_item.owner
    bought_item = current_user.buy(current_item, quantity)

    session[:message] = "~note~you bought #{bought_item.quantity}x #{bought_item.name} from #{seller.name}"
    redirect "/user/#{current_user.name}"
  end

end