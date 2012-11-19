class ItemMerge < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get "/item/:id/merge" do
    current_item_id = params[:id].to_i
    other_item_id = params[:other_item_id].to_i

    current_item = @database.item_by_id(current_item_id)
    other_item = @database.item_by_id(other_item_id)
    current_user = @database.user_by_name(session[:name])

    message = session[:message]
    session[:message] = nil
    haml :item_merge, :locals => {:user => current_user,
                                  :info => message,
                                  :item1 => current_item,
                                  :item2 => other_item }
  end


  post "/item/:id/merge" do
    current_item_id = params[:id].to_i
    other_item_id = params[:other_item_id].to_i

    current_item = @database.item_by_id(current_item_id)
    other_item = @database.item_by_id(other_item_id)
    current_user = @database.user_by_name(session[:name])

    current_item.merge(other_item)

    #Remove stored images of 'other_item'
    if other_item.pictures.size > 0
      other_item.pictures.each{ |image_url| Helper::ImageUploader.remove_image(image_url, settings.root) }
    end

    session[:message] = "message ~ Merge was successful!"
    redirect "/user/#{current_user.name}"
  end

end