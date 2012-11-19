class ItemEdit < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  # Displays the view to edit items with given id
  get '/item/:id/edit' do

    id = params[:id].to_i
    current_item = @database.item_by_id(id)
    current_user = @database.user_by_name(session[:name])

    if current_user != current_item.owner
      session[:message] = "error ~ You can't edit a item of an other user"
      redirect "/item/#{id}"
    end

    if current_item.active
      session[:message] = "error ~ You can't edit a active item"
      redirect "/item/#{id}"
    end

    message = session[:message]
    session[:message] = nil
    haml :item_edit, :locals => {:item => current_item,
                                 :info => message }
  end

  # Will edit item with given id according to given params
  # If name or price is not valid, edit will fail
  # If edit succeeds, it will redirect to profile of edited item
  post '/item/:id/edit' do

    id = params[:id].to_i
    new_name = params[:name]
    new_price = params[:price]
    current_item = @database.item_by_id(id)
    current_user = @database.user_by_name(session[:name])

    if (new_name == nil or new_name == "" or new_name.strip! == "")
      session[:message] = "error ~ Empty name!"
      redirect "/item/#{id}/edit"
    end

    begin
      !(Integer(new_price))
    rescue ArgumentError
      session[:message] = "error ~ Price was not a number!"
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


  post '/item_image_upload' do
    file = params[:file_upload]
    item_id =  params[:item_id].to_i
    current_item = @database.item_by_id(item_id)

    if file != nil
      filename = Helper::ImageUploader.upload_image(file, settings.root)
      current_item.add_image(filename)
    else
      session[:message] = "error ~ Please choose a file to upload"
    end

    redirect "item/#{item_id}/edit"
  end


  post '/item_image_delete' do
    pos =  params[:image_pos].to_i
    id = params[:item_id].to_i
    current_item = @database.item_by_id(id)
    filename = current_item.pictures[pos]

    current_item.del_image_by_nr(pos)

    Helper::ImageUploader.remove_image(filename, settings.root)
    redirect "item/#{id}/edit"
  end


  post '/item_image_to_profile' do
    im_pos =  params[:image_pos].to_i
    id =  params[:item_id].to_i
    current_item = @database.item_by_id(id)
    current_item.move_image_to_front(im_pos)
    redirect "item/#{id}/edit"
  end

end