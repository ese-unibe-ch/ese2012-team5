class BuyOrderDelete < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post '/deleteBuyOrder' do

    id = params[:id].to_i
    current_user = @database.user_by_name(session[:name])

    buy_order = @database.buy_order_by_id(id)

    if current_user == buy_order.user
      buy_order.delete
      session[:message] = "~note~you have deleted a buy order"
    end

    redirect "/user/#{current_user.name}"

  end

end