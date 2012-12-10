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
      session[:message] = "~error~Item name not found!</br>Could not create category!" # AK I'd regard this as a slight MVC violation. 
      redirect '/'
    end

    items_cleaned = @database.clear_category_from_user_items(items,current_user)
    sorted_items = @database.sort_category_by_price(items_cleaned)

    haml :buy, :locals => { :quantity => quantity,
                            :items => sorted_items }
  end


  post '/buy' do

    current_user = @database.user_by_name(session[:name])

    # AK: Put this in a helper method. If you have an upper limit for 
    # items buying then you can get rid of the explicit increment:
    # (0.upto UPPER_BOUND).each do |x| ... end
    #
    # You use this again in buy_confirm.rb, so the helper should be in a
    # separate file.
    #
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
      session[:message] = "~note~You bought nothing...congrats..." # AK couldn't you store 'note' and 'error' in different parts of the session, e.g. `session[:error] = '...'` instead of `session[:message] = "~error~..."`?
      redirect '/'
    end


    # session.default = "" # AK allows you to define, that sessions per default
                           # contain strings. Can be placed e.g. in the before
    
    # Iterate over each item that was chosen to buy
    session[:message] = "" #Note by urs: do this because of += is not allowed if its not a string, thx ruby for no declaring types, we love you....
    # AK instead of pushing into a string, you can push to an array and #join
    # afterwards
    map.each_pair do |id,quantity|

      quantity = quantity.to_i # AK why didn't you convert on the first go?
      current_item = @database.item_by_id(id.to_i)

      temp = session[:message]
      session[:message] = ""
      session[:message] += Helper::Validator.validate_integer(quantity, "quantity", 0, current_item.quantity) # NOTE by urs: quantity zero allowed
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
