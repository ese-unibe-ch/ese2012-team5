class ItemCreate < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  # Displays the view to create new items
  get '/createItem' do

    current_user = @database.user_by_name(session[:name])

    if current_user
      message = session[:message]
      session[:message] = nil
      haml :item_create, :locals => {:info => message }
    else
      session[:message] = "error ~ Log in to create items"
      redirect '/login'
    end

  end

  # Will create a new item according to given params
  # If name or price is not valid, creation will fail
  # If creation succeeds, it will redirect to profile of new item
  post '/createItem' do

    name = params[:name]
    price = params[:price]
    quantity = params[:quantity]
    description = params[:description]
    current_user = @database.user_by_name(session[:name])

    if name == nil or name == "" or name.strip! == ""
      session[:message] = "error ~ empty name!"
      redirect '/createItem'
    end

    begin
      !(Integer(price))
    rescue ArgumentError
      session[:message] = "error ~ Price was not a number!"
      redirect '/createItem'
    end

    begin
      !(Integer(quantity))
    rescue ArgumentError
      session[:message] = "error ~ Quantity was not a number!"
      redirect '/createItem'
    end

    if quantity.to_i <= 0
      session[:message] = "error ~ Quantity must be bigger than zero"
      redirect '/createItem'
    end

    if description == nil or description == ""
      session[:message] = "error ~ empty description!"
      redirect '/createItem'
    end

    new_item = Marketplace::Item.create(name, price.to_i, quantity.to_i, current_user)
    new_item.description = description

    session[:message] = "message ~ You have created #{new_item.name}"
    redirect "/item/#{new_item.id}"

  end

end