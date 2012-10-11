class ItemEdit < Sinatra::Application

  get "/edit/:id" do
    #get data from params
    id = params[:id].to_i

    current_item = Marketplace::Item.by_id(id)

    #go back if its active
    if(current_item.active)
      redirect "/item/#{id}"
    end

    message = session[:message]
    session[:message] = nil
    haml :edit_item, :locals => { :items => Marketplace::Item.all,
                                  :item => current_item,
                                  :info => message                }
  end


  post "/edit/:id" do
    #get data from params
    id = params[:id].to_i
    new_name = params[:name]
    new_price = params[:price]

    current_item = Marketplace::Item.by_id(id)

    #check if the name is valid
    if(new_name == nil or new_name == "")
      session[:message] = "empty name!"
      redirect "/edit/#{id}"
    end

    #check if the price is valid
    begin
      !(Integer(new_price))

      rescue ArgumentError
        session[:message] = "price was not a number!"
        redirect "/edit/#{id}"
    end

    #overwrite data
    current_item.name = new_name
    current_item.price = new_price.to_i

    redirect "/item/#{id}"
  end
end