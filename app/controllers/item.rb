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


    #only possible action while activity

    #check if a session is in progress and if the current user is owner
    if session[:name] == current_item.owner.name


      #allows to activate and deactivate item
      if params[:activation] == 'deactivate'
        current_item.deactivate
      end

      if params[:activation] == 'activate'
        current_item.activate
      end


      haml :own_item_profile, :locals => {:items => Marketplace::Item.all,
                                          :item => current_item}
    else


      actualUser = Marketplace::User.by_name(session[:name])

      actualUser.buy(current_item)

      if actualUser.name == current_item.owner.name
        haml :own_item_profile, :locals => {:items => Marketplace::Item.all,
                                            :item => current_item}
      else


        haml :item_profile, :locals => {:items => Marketplace::Item.all,
                                        :item => current_item}
      end
    end
  end
end