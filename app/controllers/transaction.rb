class Transaction < Sinatra::Application

  get "/buy" do
    redirect "/"
  end

  post '/buy' do
    #
    buyer_name = params[:buyer]
    item_id = params[:item_id]
    seller_name = session[:seller]
    buyer = Marketplace::User.with_name(buyer_name)
    seller = Marketplace::User.with_name(seller_name)

    item = owner.list_all_items.detect { |i| i.id == item_id }

    if user.buy_item(item)
      session[:message] = "You bought #{item.name} from #{seller_name}"
    else
      session[:message] = "Not enough credits to buy #{item.name}"
    end

    redirect "/"
  end

end