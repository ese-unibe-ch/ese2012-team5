class ItemCreate < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


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


  post '/createItem' do

    name = params[:name]
    price = params[:price]
    quantity = params[:quantity]
    current_user = @database.user_by_name(session[:name])

    #TODO add helper here
    if name == nil or name == "" or name.strip! == ""
      session[:message] = "error ~ empty name!"
      redirect '/createItem'
    end

    #TODO add helper here
    begin
      !(Integer(price))
    rescue ArgumentError
      session[:message] = "error ~ Price was not a number!"
      redirect '/createItem'
    end

    #TODO add helper here
    begin
      !(Integer(quantity))
    rescue ArgumentError
      session[:message] = "error ~ Quantity was not a number!"
      redirect '/createItem'
    end

    #TODO add helper here
    if quantity.to_i <= 0
      session[:message] = "error ~ Quantity must be bigger than zero"
      redirect '/createItem'
    end

    new_item = Marketplace::Item.create(name, price.to_i, quantity.to_i, current_user)

    session[:message] = "message ~ You have created #{new_item.name}"
    redirect "/item/#{new_item.id}"
  end

end