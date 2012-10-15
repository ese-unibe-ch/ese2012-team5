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

    #this check if an Item with the same name already exists
    same_name_item=false
    current_user.items.each { |item| same_name_item = true if item.name.to_s == name }
    #to create this ite after checkin is important because of false positive
    current_item = Marketplace::Item.create(name, price.to_i, quantity.to_i, current_user)

    if same_name_item

      haml :merge_items, :locals => {:new_item => current_item}
    else

      redirect "/item/#{current_item.id}"
    end
  end

end