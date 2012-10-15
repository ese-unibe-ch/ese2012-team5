class ItemCreate < Sinatra::Application

  # Displays the view to create new items




  get "/add_item" do

    current_user = Marketplace::User.by_name(session[:name])


    if current_user
      message = session[:message]
      session[:message] = nil
      haml :item_create, :locals => {:info => message}
    else
      session[:message] = "Log in to create items"
      redirect '/login'
    end

  end

  # Will create a new item according to given params
  # If name or price is not valid, creation will fail
  # If creation succeeds, it will redirect to profile of new item
  post "/add_item" do

    name = params[:name]
    price = params[:price]
    quantity = params[:quantity]
    current_user = Marketplace::User.by_name(session[:name])


    if (name == nil or name == "" or name.strip! == "")
      session[:message] = "empty name!"
      redirect '/add_item'
    end


    begin
      !(Integer(price))

    rescue ArgumentError
      session[:message] = "price was not a number!"
      redirect '/add_item'
    end

    begin
      !(Integer(quantity))

    rescue ArgumentError
      session[:message] = "quantity was not a number!"
      redirect '/add_item'
    end

    if quantity.to_i <= 0
      session[:message] = "quantity must be bigger than 0"
      redirect '/add_item'
    end

    current_item = Marketplace::Item.create(name, price.to_i, quantity.to_i, current_user)

    redirect "/item/#{current_item.id}"
  end

end