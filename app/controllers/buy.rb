class Buy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])

    redirect '/login' unless @current_user
  end


  get '/buy' do
    quantity = params[:quantity].to_i
    category_name = params[:category]


    category = Helper::Categorizer.category_by_name_without(category_name, @current_user)
    sorted_category = Helper::Categorizer.sort_category_by_price(category)

    if sorted_category.nil?
      session[:message] = "~error~Item name not found!~error~Could not create category!"
      redirect '/'
    end

    haml :buy, :locals => { :quantity => quantity,
                            :items => sorted_category }
  end

  post '/buy' do
    #TODO factor this out
            # Create a hash-table
            # key is the 'item.id'
            # value is the 'quantity' to buy
            x = 0
            map = Hash.new
            while params.key?("id#{x}")
              if params["quantity#{x}"].to_i != 0
                map[params["id#{x}"]] = params["quantity#{x}"].to_i
              end
              x = x + 1
            end
    #TODO yep that

    # If the map is empty the user bought nothing
    if map.empty?
      session[:message] = "~note~You bought nothing...congrats..."
      redirect '/'
    end


    # Iterate over each item that was chosen to buy
    session[:message] = "" #Note by urs: do this because of += is not allowed if its not a string, thx ruby for no declaring types, we love you....
    map.each_pair do |id,quantity|
      current_item = @database.item_by_id(id.to_i)

      temp = session[:message]
      session[:message] = ""
      session[:message] += Helper::Validator.validate_integer(quantity, "quantity", 0, current_item.quantity) # NOTE by urs: quantity zero allowed
      session[:message] += "~error~you can't buy this item!" if !@current_user.can_buy_item?(current_item, quantity)
      session[:message] += "~error~not for sell!" if !current_item.active
      session[:message] += "~error~not enough credits!" if !@current_user.has_enough_credits?(current_item.price * quantity)
      if session[:message] != ""
        redirect "/item/#{current_item.id}"
      end
      session[:message] = temp

      seller = current_item.owner
      bought_item = @current_user.buy(current_item, quantity)

      session[:message] += "~note~you bought #{bought_item.quantity}x #{bought_item.name} from #{seller.name}."
    end

    redirect '/'
  end

end