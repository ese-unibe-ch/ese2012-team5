class BuyItem
  get "/buyItem/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)

    current_user = Marketplace::User.by_name(session[:name])

    #check if a user is logged in
    if current_user
      #prevent failer by url tipping of owner
      if current_user.name != current_item.owner
        current_user.buy(current_item)

        redirect "/item/#{current_item.id}"

      end
    else


      haml :notLoggedIn

    end

  end


end