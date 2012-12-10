class BuyOrderCreate < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])

    redirect '/login' unless @current_user
  end


  get '/createBuyOrder' do
    message = session[:message]
    session[:message] = nil
    haml :buy_order_create, :locals => {:info => message }
  end

  post '/createBuyOrder' do
    item_name = params[:item_name]
    max_price = params[:max_price]


    session[:message] = ""
    session[:message] += Helper::Validator.validate_string(item_name, "name")
    session[:message] += Helper::Validator.validate_integer(max_price, "max price", 1, nil)
    if session[:message] != ""
      redirect '/createBuyOrder'
    end

    # Check if buy_order is already satisfiable
    # If yes, go back home and provide a link to such an item
    possible_items = Marketplace::Database.instance.item_by_name(item_name)
    possible_item = possible_items.detect{ |item| item.name == item_name and
                                  item.price < max_price.to_i and
                                  item.owner != @current_user and
                                  item.active }
    if possible_item
      session[:message] = "~note~the item your willing to buy is already available.~item~#{possible_item.id}~#{possible_item.name}"
      redirect '/'
    else
      Marketplace::BuyOrder.create(item_name, max_price.to_i, @current_user)
      session[:message] = "~note~you have created a new buy order."
      redirect "/user/#{@current_user.name}"
    end

  end

end