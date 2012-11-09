class ItemEdit < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # TODO rewrite uploadcode!
  @@id = 1

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
    new_quantity = params[:quantity]
    new_auction_end_time = params[:auction_end_time]
    new_increment = params[:increment]
    current_item = @database.item_by_id(id)
    current_user = @database.user_by_name(session[:name])

    # Checks
    if (new_name == nil or new_name == "" or new_name.strip! == "")
      session[:message] = "error ~ Empty name!"
      redirect "/item/#{id}/edit"
    end

    if !@database.item_name_allowed?(new_name,current_item)
      session[:message] = "error ~ Item name not allowed! You may not use names of items up for auction."
      redirect "/item/#{id}/edit"
    end

    # price
    begin
      !(Integer(new_price))
    rescue ArgumentError
      session[:message] = "error ~ Price was not a number!"
      redirect "/item/#{id}/edit"
    end
    new_price = new_price.to_i
    if new_price <= 0
      session[:message] = "error ~ Price was negative or null!"
      redirect "/item/#{id}/edit"
    end

    # quantity
    begin
      !(Integer(new_quantity))
    rescue ArgumentError
      session[:message] = "error ~ Quantity was not a number!"
      redirect "/item/#{id}/edit"
    end
    new_quantity = new_quantity.to_i
    if new_quantity <= 0
      session[:message] = "error ~ Quantity was negative or null!"
      redirect "/item/#{id}/edit"
    end

    if !params[:useauction]
      new_auction_end_time = nil
    end


    set_up_for_auction = false
    set_up_for_auction = true if new_auction_end_time && new_auction_end_time.length > 0
    # easier to read than "auction = new_auction_end_time && new_auction_end_time.length > 0"

    if set_up_for_auction && !@database.item_auction_possible?(new_name,new_quantity,current_item)
      session[:message] = "error ~ Cannot put this item up for auction! Quantity must be 1 and name unique."
      redirect "/item/#{id}/edit"
    end

    if set_up_for_auction

      begin
      new_auction_end_time = Time.parse(new_auction_end_time)
      rescue
        new_auction_end_time = nil
      end
      # TODO: check format...

      if !new_auction_end_time
        session[:message] = "error ~ Invalid time format."
        redirect "/item/#{id}/edit"
      end

      MINIMAL_AUCTION_TIME_SECONDS = 1#3*60
      if new_auction_end_time < Time.now + (MINIMAL_AUCTION_TIME_SECONDS) #can add seconds, http://stackoverflow.com/questions/5905861/how-do-i-add-two-weeks-to-time-now
        session[:message] = "error ~ Minimum for auction duration is #{MINIMAL_AUCTION_TIME_SECONDS} seconds."
        redirect "/item/#{id}/edit"
      end

      # increment
      begin
        !(Integer(new_quantity))
      rescue ArgumentError
        session[:message] = "error ~ Increment was not a number!"
        redirect "/item/#{id}/edit"
      end
      new_increment = new_increment.to_i
      if new_increment <= 0
        session[:message] = "error ~ Increment was negative or null!"
        redirect "/item/#{id}/edit"
      end
    end

    # all checks passed

    current_item.name = new_name
    current_item.price = new_price
    current_item.quantity = new_quantity
    if set_up_for_auction
      auction = Marketplace::Auction.create(new_auction_end_time, new_increment, new_price)
      item.set_auction Auction
    end

    # Check if the creator already owns a similar item, do we need to merge these items?
    need_merge = false
    current_user.items.each{ |item| need_merge = true if !item.equal?(current_item) and item.mergeable?(current_item)}

    if need_merge
      haml :item_merge, :locals => {:new_item => current_item}
    else
      redirect "/item/#{id}"
    end

  end

  # saves picture with name '@@id' in public/item_images
  post '/item_image_upload' do
    file = params[:file_upload]
    item_id =  params[:item_id].to_i
    current_item = @database.item_by_id(item_id)

    if file != nil
      filename = "#{@@id}"
      current_item.add_image(filename)
      @@id = @@id + 1

      FileUtils::cp(file[:tempfile].path, "app/public/item_images/#{filename}")
    else
      session[:message] = "error ~ Please choose a file to upload"
    end

    redirect "item/#{item _id.to_s}/edit"
  end

  #retrieve picture in item_images
  get '/item_images/:filename' do
    send_file("app/public/item_images/#{filename}")
  end

  #delete image (only link not physical)
  post '/item_image_delete' do
    im_pos =  params[:image_pos].to_i
    id =  params[:item_id].to_i
    current_item = @database.item_by_id(id)
    item_image_pos = current_item.pictures[im_pos]
    current_item.del_image_by_nr(im_pos)
    FileUtils.remove("app/public/item_images/#{filename}")
    redirect "item/#{id.to_s}/edit"
  end

  #move this image to the first position in the array
  post '/item_image_to_profile' do
    im_pos =  params[:image_pos].to_i
    id =  params[:item_id].to_i
    current_item = @database.item_by_id(id)
    current_item.move_image_to_front(im_pos)
    redirect "item/#{id.to_s}/edit"
  end

end