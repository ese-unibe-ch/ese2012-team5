class ItemEdit < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
  end

  # Displays item_edit view to user that owns the item if item is deactivated
  get '/item/:id/edit' do
    redirect '/login' unless @current_user
    current_item = @database.item_by_id(params[:id].to_i)

    if @current_user != current_item.owner
      session[:message] = "~error~you can't edit a item of an other user."
      redirect "/item/#{current_item.id}"
    end

    if current_item.active
      session[:message] = "~error~you can't edit an active item, deactivate it first."
      redirect "/item/#{current_item.id}"
    end

    message = session[:message]
    session[:message] = nil
    haml :item_edit, :locals => {:item => current_item,
                                 :info => message }
  end

  # Takes care of editing an item's attributes (name, price, quantity, description)
  post '/item/:id/edit' do
    current_item = @database.item_by_id(params[:id].to_i)
    new_name = params[:name]
    new_price = params[:price].to_i
    new_quantity = params[:quantity].to_i
    new_description = params[:description]


    session[:message] = ""
    session[:message] += Validator.validate_string(new_name, "name")
    session[:message] += Validator.validate_integer(new_price, "price", 1, nil)
    session[:message] += Validator.validate_integer(new_quantity, "quantity", 1, nil)
    session[:message] += Validator.validate_string(new_description, "description")
    if session[:message] != ""
      redirect "/item/#{current_item.id}/edit"
    end

    current_item.name = new_name
    current_item.price = new_price
    current_item.quantity = new_quantity
    current_item.description = new_description

    redirect "/item/#{current_item.id}"
  end

  # Takes care of adding an image to an item.
  post '/item/:id/image_upload' do
    current_item = @database.item_by_id(params[:id].to_i)
    file = params[:file_upload]

    if file != nil
      filename = ImageUploader.upload_image(file, settings.root)
      current_item.add_image(filename)
    else
      session[:message] = "~error~please choose a file to upload"
    end

    redirect "item/#{current_item.id}/edit"
  end

  # Takes care of deleting an image of an item.
  post '/item/:id/image_delete' do
    current_item = @database.item_by_id(params[:id].to_i)
    pos =  params[:image_pos].to_i

    current_item.delete_image_at(pos)

    redirect "item/#{current_item.id}/edit"
  end

  post '/item/:id/image_to_profile' do
    current_item = @database.item_by_id(params[:id].to_i)
    pos = params[:image_pos].to_i

    current_item.select_front_image(pos)

    redirect "item/#{current_item.id}/edit"
  end

  # Adds a new entry in the log with a new timestamp and the description & log from
  # Is called if an earlier entry in the description log is selected to use
  post '/item/:id/add_description' do
    current_item = @database.item_by_id(params[:id].to_i)
    timestamp =  params[:timestamp]
    description = current_item.description_from_log(timestamp)
    price = current_item.price_from_log(timestamp)

    # Only add new description into log if status of description and price changed
    if current_item.status_changed(description, price.to_i)
      current_item.add_description(Time.now, description, price.to_i)
      session[:message] = "~note~description and price reset to earlier version"
    else
      session[:message] = "~error~description and price already have these values"
    end

    redirect "item/#{current_item.id}"
  end

end