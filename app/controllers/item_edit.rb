class ItemEdit < Sinatra::Application

  # Displays the view to edit items with given id
  get "/item/:id/edit" do

    id = params[:id].to_i
    current_item = Marketplace::Item.by_id(id)
    current_user = Marketplace::User.by_name(session[:name])


    if current_user != current_item.owner
      session[:message] = "You can't edit a item of an other user"
      redirect "/item/#{id}"
    end

    if current_item.active
      session[:message] = "You can't edit a active item"
      redirect "/item/#{id}"
    end

    message = session[:message]
    session[:message] = nil
    haml :item_edit, :locals => {:item => current_item,
                                 :info => message}
  end

  # Will edit item with given id according to given params
  # If name or price is not valid, edit will fail
  # If edit succeeds, it will redirect to profile of edited item
  post "/item/:id/edit" do

    id = params[:id].to_i
    new_name = params[:name]
    new_price = params[:price]
    current_item = Marketplace::Item.by_id(id)
    current_user = Marketplace::User.by_name(session[:name])


    if (new_name == nil or new_name == "" or new_name.strip! == "")
      session[:message] = "empty name!"
      redirect "/item/#{id}/edit"
    end

    begin
      !(Integer(new_price))
    rescue ArgumentError
      session[:message] = "price was not a number!"
      redirect "/item/#{id}/edit"
    end

    current_item.name = new_name
    current_item.price = new_price.to_i

    # Check if the creator already owns a similar item, do we need to merge these items?
    need_merge = false
    current_user.items.each{ |item| need_merge = true if !item.equal?(current_item) and item.mergeable?(current_item)}


    if need_merge
      haml :item_merge, :locals => {:new_item => current_item}
    else
      redirect "/item/#{id}"
    end

  end

end