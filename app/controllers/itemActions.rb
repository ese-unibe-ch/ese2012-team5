class ItemActions < Sinatra::Application


  #link to correct item page
  get "/item/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)
    current_user = Marketplace::User.by_name(session[:name])
    #check if a session is in progress and if the current user is owner
    if session[:name] == current_item.owner.name
      haml :item_profile_own, :locals => {:items => Marketplace::Item.all,
                                          :item => current_item}
    else

      if current_user
        userCredits  = current_user.credits
      else
        userCredits=0
      end

      haml :item_profile, :locals => {:items => Marketplace::Item.all,
                                      :item => current_item,
                                      :userCredits => userCredits}
    end
  end


end