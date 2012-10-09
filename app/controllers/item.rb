class Item < Sinatra::Application



  #link to correct item page
  get "/item/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)

    #check if a session is in progress and if the current user is owner
    if session[:name] == current_item.owner.name
      haml :own_item_profile, :locals => {:items => Marketplace::Item.all,
                                          :item => current_item}
    else
      haml :item_profile, :locals => {:items => Marketplace::Item.all,
                                      :item => current_item}
    end
  end

  post "/item/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)

    #check if a session is in progress and if the current user is owner
    if session[:name] == current_item.owner.name
      haml :own_item_profile, :locals => {:items => Marketplace::Item.all,
                                          :item => current_item}
    else
      haml :item_profile, :locals => {:items => Marketplace::Item.all,
                                      :item => current_item}
    end
  end
end