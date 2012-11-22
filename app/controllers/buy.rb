class Buy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/buy' do
    redirect '/login' unless session[:name]

    quantity = params[:quantity].to_i
    category = params[:category]
    current_user = @database.user_by_name(session[:name])
    items = @database.category_with_name(category)

    if items == nil
      session[:message] = "~error~Item name not found!</br>Could not create category!"
      redirect '/'
    end

    items_cleaned = @database.clear_category_from_user_items(items,current_user)
    sorted_items = @database.sort_category_by_price(items_cleaned)

    haml :buy, :locals => { :quantity => quantity,
                            :items => sorted_items }
  end


  post '/buy' do

    current_user = @database.user_by_name(session[:name])

    # Create a hash-table
    # key is the 'item.id'
    # value is the 'quantity' to buy
    x = 0
    map = Hash.new
    while params.key?("id#{x}")
      if params["quantity#{x}"].to_i != 0
        map[params["id#{x}"]] = params["quantity#{x}"]
      end
      x = x + 1
    end

    # If the map is empty the user bought nothing
    if map.empty?
      session[:message] = "~note~You bought nothing...congrats..."
      redirect '/'
    end


    # Iterate over each item that was chosen to buy
    session[:message] = "" #Note by urs: do this because of += is not allowed if its not a string, thx ruby for no declaring types, we love you....
    map.each_pair do |id,quantity|

      quantity = quantity.to_i
      current_item = @database.item_by_id(id.to_i)

      temp = session[:message]
      session[:message] = ""
      session[:message] += Helper::Validator.validate_integer(quantity, "quantity", -1, current_item.quantity) # NOTE by urs: quantity zero allowed
      session[:message] += "~error~you can't buy this item!" if !current_user.can_buy_item?(current_item, quantity)
      session[:message] += "~error~not for sell!" if !current_item.active
      session[:message] += "~error~not enough credits!" if !current_user.enough_credits(current_item.price * quantity)
      if session[:message] != ""
        redirect "/item/#{current_item.id}"
      end
      session[:message] = temp

      seller = current_item.owner
      bought_item = current_user.buy(current_item, quantity)

      session[:message] += "~note~you bought #{bought_item.quantity}x #{bought_item.name} from #{seller.name}."
    end
    redirect '/'

  end

end