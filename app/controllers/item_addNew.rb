class ItemEdit < Sinatra::Application

  get "/add_item" do

    current_user = Marketplace::User.by_name(session[:name])

    if  current_user
      message = session[:message]
      session[:message] = nil
      haml :addNew_item, :locals => {:info => message}
    else
      "You are not logged in"
    end
  end


  post "/add_item" do
    #get data from params

    name = params[:name]
    price = params[:price]
    current_user = Marketplace::User.by_name(session[:name])
    #check if the name is valid
    if (name == nil or name == "" or name.strip! == "")
      session[:message] = "empty name!"
      redirect "/add_item"
    end

    #check if the price is valid
    begin
      !(Integer(price))

    rescue ArgumentError
      session[:message] = "price was not a number!"
      redirect "/add_item"
    end


    current_item = Marketplace::Item.create(name, price.to_i, current_user)

    redirect "/item/#{current_item.id}"
  end
end