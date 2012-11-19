class BuyOrderDelete < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post '/deleteBuyOrder' do

    id = params[:id]
    current_user = @database.user_by_name(session[:name])

    buy_order = @database.buy_order_by_id(id.to_i)

    if current_user == buy_order.user
      @database.delete_buy_order(buy_order)
      session[:message] = "message ~ You have deleted a buy order"
    end

    redirect "/user/#{current_user.name}"

  end

end