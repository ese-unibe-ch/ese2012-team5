class BuyOrderCreate < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/createBuyOrder' do

    current_user = @database.user_by_name(session[:name])

    if current_user
      message = session[:message]
      session[:message] = nil
      haml :buy_order_create, :locals => {:info => message }
    else
      session[:message] = "error ~ Log in to create buy orders"
      redirect '/login'
    end

  end


  post '/createBuyOrder' do

    item_name = params[:item_name]
    max_price = params[:max_price]
    current_user = @database.user_by_name(session[:name])

    if item_name == nil or item_name == "" or item_name.strip! == ""
      session[:message] = "error ~ empty name!"
      redirect '/createBuyOrder'
    end

    begin
      !(Integer(max_price))
    rescue ArgumentError
      session[:message] = "error ~ Price was not a number!"
      redirect '/createBuyOrder'
    end

    # Create new buy order
    Marketplace::BuyOrder.create(item_name, max_price.to_i, current_user)

    session[:message] = "message ~ You have created a new buy order"
    redirect "/user/#{current_user.name}"

  end

end