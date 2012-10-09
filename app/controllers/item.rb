class Item < Sinatra::Application

  get "/items" do


    items= Marketplace::Item.all
    actualUser = Marketplace::User.by_name(session[:name])
    haml :item, :locals => {:items => items, user => actualUser}

  end

  post "/items" do


    items= Marketplace::Item.all

    itemToBuy = Marketplace::Item.by_id(Integer(params[:Item]))

    actualUser.buy(itemToBuy)

    haml :item, :locals => {:items => items, user => actualUser}

  end

  #link to correct item page
  get "/item/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)

    #check if a session is in progress and if the current user is owner
    if session[:name] == current_item.owner
      haml :own_item_profile, :locals => {:items => Marketplace::Item.all,
                                          :item => current_item}
    else
      haml :item_profile, :locals => {:items => Marketplace::Item.all,
                                      :item => current_item}
    end
  end
end