class ActivateItem
  get "/activateItem/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)

    #check if a session is in progress and if the current user is owner
    if session[:name] == current_item.owner.name
        if current_item.active
          current_item.deactivate
        else
          current_item.activate
        end

        redirect "/item/#{current_item.id}"
    else

     "Your are not the owner"

    end

   end
end