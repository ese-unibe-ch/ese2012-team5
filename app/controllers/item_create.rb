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
      session[:message] = "~error~log in to create items!"
      redirect '/login'
    end

  end


  post '/createItem' do

    name = params[:name]
    price = params[:price]
    quantity = params[:quantity]
    description = params[:description]
    current_user = @database.user_by_name(session[:name])


    session[:message] = ""
    session[:message] += Helper::Validator.validate_string(name, "name")
    session[:message] += Helper::Validator.validate_integer(price, "price", 1, nil)
    session[:message] += Helper::Validator.validate_integer(quantity, "quantity", 1, nil)
    session[:message] += Helper::Validator.validate_string(description, "description")
    if session[:message] != ""
      redirect '/createItem'
    end

    new_item = Marketplace::Item.create(name, price.to_i, quantity.to_i, current_user)
    time_now = Time.new
    # Add new description into log and delete standard entry
    new_item.description_log.clear
    new_item.add_description(time_now,description,price.to_i)

    session[:message] = "~note~you have created #{new_item.name}"
    redirect "/item/#{new_item.id}"
  end

end