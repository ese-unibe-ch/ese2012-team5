class Buy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get '/buy' do

    redirect '/login' unless session[:name]

    quantity = params[:quantity].to_i
    category = params[:category]
    items = @database.category_with_name(category)
    sorted_items = @database.sort_category_by_price(items)

    if items == nil
      session[:message] = "Item name not found - could not create category"
      redirect '/'
    end

    message = session[:message]
    session[:message] = nil
    haml :buy, :locals => { :info => message,
                            :quantity => quantity,
                            :items => sorted_items }
  end


  post '/buy' do

    current_user = @database.user_by_name(session[:name])
    params.each do |key, param|
      params[key] = param
    end

    x = 0
    map = Hash.new
    while params.key?("id#{x}")
      if params["quantity#{x}"].to_i != 0
        map[params["id#{x}"]] = params["quantity#{x}"]
      end
      x = x + 1
    end

    if map.empty?
      session[:message] = "You bought nothing...congrats..."
      redirect "/"
    end


    session[:message] = ""
    map.each_pair do |id,quantity|

      quantity = quantity.to_i
      current_item = @database.item_by_id(id.to_i)

      # Check for guests playing around
      if !current_user
        session[:message] = "Log in to buy items"
        redirect '/login'
      end

      # Checks if quantity is wrong
      if quantity <= 0 or quantity > current_item.quantity
        session[:message] = "Quantity #{quantity} not valid!"
        redirect "/item/#{current_item.id}"
      end

      # Check if user isn't able to buy item
      if !user_can_buy_item?(current_user, current_item, quantity)
        session[:message] = "You can't buy this item! Not active or not enough credits"
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

      seller = item_to_sell.owner

      # Let the buyer buy the item
      current_user.buy(item_to_sell)

      session[:message] << "You bought #{quantity}x #{current_item.name} from #{seller.name}</br>"
    end

    current_user = @database.user_by_name(session[:name])
    current_items = current_user.items
    categorized_items = @database.categories_items
    sorted_categorized_items = @database.sort_categories_by_price(categorized_items)

    message = session[:message]
    session[:message] = nil
    haml :main, :locals => {  :info => message,
                              :current_items => current_items,
                              :current_user => current_user,
                              :categories => sorted_categorized_items }
  end

  def user_can_buy_item?(current_user, current_item, quantity)
    current_user.name != current_item.owner and
        current_item.price * quantity <= current_user.credits and
        current_item.active
  end

end