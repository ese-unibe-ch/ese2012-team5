class BuyItem
  get "/buyItem/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)

    current_user = Marketplace::User.by_name(session[:name])


    if current_user

      current_user.buy(current_item)

      redirect "/item/#{current_item.id}"

    else



      haml :notLoggedIn

    end

  end


end