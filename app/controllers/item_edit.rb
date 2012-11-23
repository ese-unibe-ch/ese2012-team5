class ItemEdit < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/item/:id/edit' do

    id = params[:id].to_i
    current_item = @database.item_by_id(id)
    current_user = @database.user_by_name(session[:name])

    if current_user != current_item.owner
      session[:message] = "~error~you can't edit a item of an other user."
      redirect "/item/#{id}"
    end

    if current_item.active
      session[:message] = "~error~you can't edit an active item.</br>deactivate it first."
      redirect "/item/#{id}"
    end

    message = session[:message]
    session[:message] = nil
    haml :item_edit, :locals => {:item => current_item,
                                 :info => message }
  end


  post '/item/:id/edit' do

    id = params[:id].to_i
    new_name = params[:name]
    new_price = params[:price]
    current_item = @database.item_by_id(id)


    session[:message] = ""
    session[:message] += Helper::Validator.validate_string(new_name, "name")
    session[:message] += Helper::Validator.validate_integer(new_price, "price", 1, nil)
    if session[:message] != ""
      redirect "/item/#{id}/edit"
    end

    current_item.name = new_name
    current_item.price = new_price.to_i

    redirect "/item/#{id}"
  end


  post '/item_image_upload' do
    file = params[:file_upload]
    item_id =  params[:item_id].to_i
    current_item = @database.item_by_id(item_id)

    if file != nil
      filename = Helper::ImageUploader.upload_image(file, settings.root)
      current_item.add_image(filename)
    else
      session[:message] = "~error~please choose a file to upload"
    end

    redirect "item/#{item_id}/edit"
  end


  post '/item_image_delete' do
    pos =  params[:image_pos].to_i
    id = params[:item_id].to_i
    current_item = @database.item_by_id(id)
    current_item.delete_image_at(pos)
    redirect "item/#{id}/edit"
  end


  post '/item_image_to_profile' do
    pos =  params[:image_pos].to_i
    id =  params[:item_id].to_i
    current_item = @database.item_by_id(id)
    current_item.select_front_image(pos)
    redirect "item/#{id}/edit"
  end

end