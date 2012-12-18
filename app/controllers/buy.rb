class Buy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
    session.default = ""
  end

  # Displays the Buy view where the current user can change the quantity of the choosen items.
  # If multiple similar items exist they will be available here.
  get '/buy' do
    redirect '/login' unless @current_user
    quantity = params[:quantity].to_i
    category_name = params[:category]

    category = Categorizer.category_by_name_without(category_name, @current_user)
    sorted_category = Categorizer.sort_category_by_price(category)

    if sorted_category.nil?
      session[:message] = "~error~Item name not found!~error~Could not create category!"
      redirect '/'
    end

    haml :buy, :locals => { :current_user => @current_user,
                            :quantity => quantity,
                            :items => sorted_category }
  end

  # Takes care of buy process if items are bought via main and buy confirm views.
  # See also item_buy.rb controller for items bought via item view.
  post '/buy' do

    map = Checker.create_buy_map(params)

    if map.empty?
      session[:message] = "~note~You bought nothing...congrats..."
      redirect '/'
    end

    # Iterate over each item that was chosen to buy
    map.each_pair do |id,quantity|
      current_item = @database.item_by_id(id.to_i)

      temp = session[:message]
      session[:message] = ""
      session[:message] += Validator.validate_integer(quantity, "quantity", 0, current_item.quantity) # NOTE by urs: quantity zero allowed
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