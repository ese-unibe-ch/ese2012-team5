class ItemEdit < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_item = @database.item_by_id(params[:id].to_i)
    @current_user = @database.user_by_name(session[:name])
  end


  get '/item/:id/edit' do
    if @current_user != @current_item.owner
      session[:message] = "~error~you can't edit a item of an other user."
      redirect "/item/#{@current_item.id}"
    end

    if @current_item.active
      session[:message] = "~error~you can't edit an active item, deactivate it first."
      redirect "/item/#{@current_item.id}"
    end

    message = session[:message]
    session[:message] = nil
    haml :item_edit, :locals => {:item => @current_item,
                                 :info => message }
  end

  post '/item/:id/edit' do
    new_name = params[:name]
    new_price = params[:price]
    new_quantity = params[:quantity]
    new_description = params[:description]


    session[:message] = ""
    session[:message] += Helper::Validator.validate_string(new_name, "name")
    session[:message] += Helper::Validator.validate_integer(new_price, "price", 1, nil)
    session[:message] += Helper::Validator.validate_integer(new_quantity, "quantity", 1, nil)
    session[:message] += Helper::Validator.validate_string(new_description, "description")
    if session[:message] != ""
      redirect "/item/#{id}/edit"
    end

    @current_item.name = new_name
    @current_item.price = new_price
    @current_item.quantity = new_quantity
    @current_item.description = new_description

    redirect "/item/#{@current_item.id}"
  end

  post '/item_image_upload' do
    file = params[:file_upload]

    if file != nil
      filename = Helper::ImageUploader.upload_image(file, settings.root)
      @current_item.add_image(filename)
    else
      session[:message] = "~error~please choose a file to upload"
    end

    redirect "item/#{@current_item.id}/edit"
  end

  post '/item_image_delete' do
    pos =  params[:image_pos].to_i

    @current_item.delete_image_at(pos)

    redirect "item/#{@current_item.id}/edit"
  end

  post '/item_image_to_profile' do
    pos =  params[:image_pos].to_i

    @current_item.select_front_image(pos)

    redirect "item/#{@current_item.id}/edit"
  end

  # Adds a new entry in the log with a new timestamp and the description & log from
  # Is called if an earlier entry in the description log is selected to use
  post '/item_add_description' do
    timestamp =  params[:timestamp]
    description = @current_item.description_from_log(timestamp)
    price = @current_item.price_from_log(timestamp)

    # Only add new description into log if status of description and price changed
    if @current_item.status_changed(description, price.to_i)
      time_now = Time.new
      @current_item.add_description(time_now, description, price.to_i)
      session[:message] = "~note~description and price reset to earlier version"
    else
      session[:message] = "~error~description and price already have these values"
    end

    redirect "item/#{@current_item.id}"
  end

end