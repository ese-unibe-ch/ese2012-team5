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
      session[:message] = "error ~ Item name not found!</br>Could not create category!"
      redirect '/'
    end

    items_cleaned = @database.clear_category_from_user_items(items,current_user)
    sorted_items = @database.sort_category_by_price(items_cleaned)

    haml :buy, :locals => { :quantity => quantity,
                            :items => sorted_items }
  end


  post '/buy' do

    current_user = @database.user_by_name(session[:name])

    # Check for guests playing around
    if !current_user
      session[:message] = "error ~ Log in to buy items..how did you end up there anyway?!"
      redirect '/login'
    end

    # Create a hash-table
    # key = item.id
    # value = quantity to buy of item.id(corresponding key)
    x = 0
    map = Hash.new
    while params.key?("id#{x}")
      if params["quantity#{x}"].to_i != 0
        map[params["id#{x}"]] = params["quantity#{x}"]
      end
      x = x + 1
    end

    if map.empty?
      session[:message] = "message ~ You bought nothing...congrats..."
      redirect '/'
    end

    session[:message] = "message ~ "
    map.each_pair do |id,quantity|

      quantity = quantity.to_i
      current_item = @database.item_by_id(id.to_i)

      # Checks if quantity is wrong
      if quantity <= 0 or quantity > current_item.quantity
        session[:message] = "error ~ Quantity #{quantity} not valid!"
        redirect "/item/#{current_item.id}"
      end

      # Check if user isn't able to buy item
      if !current_user.can_buy_item?(current_item, quantity)
        session[:message] = "error ~ You can't buy this item!</br>"
        session[:message] << "Not for sell!" if !current_item.active
        session[:message] << "Not enough credits!" if !current_user.enough_credits(current_item.price * quantity)
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

      # Store seller
      seller = item_to_sell.owner

      # Let the buyer buy the item
      current_user.buy(item_to_sell)
      session[:message] << "You bought #{quantity}x #{current_item.name} from #{seller.name}</br>"
    end

    redirect '/'

  end

end