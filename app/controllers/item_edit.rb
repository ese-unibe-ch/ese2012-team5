class ItemEdit < Sinatra::Application

  get "/edit/:id" do
    id = params[:id].to_i

    current_item = Marketplace::Item.by_id(id)

    if(current_item.active)
      redirect "/item/#{id}"
    end

    message = session[:message]
    session[:message] = nil
    haml :edit_item, :locals => {:items => Marketplace::Item.all,
                                 :item => current_item,
                                  :info => message}

  end


  post "/edit/:id" do

    id = params[:id].to_i
    new_name = params[:name]
    new_price = params[:price].to_i

    current_item = Marketplace::Item.by_id(id)

    if(new_name == nil or new_name == "")
      session[:message] = "empty name!"
      redirect "/edit/#{id}"
    end

    if(!(new_price.is_a? Integer))
      session[:message] = "price was not a number!"
      redirect "/edit/#{id}"
    end

    current_item.name = new_name
    current_item.price = new_price

    redirect "/item/#{id}"
  end
end