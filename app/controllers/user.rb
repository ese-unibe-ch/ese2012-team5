class User < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get "/user/:name" do

    current_user = @database.user_by_name(session[:name])
    user = @database.user_by_name(params[:name])
    message = session[:message]
    session[:message] = nil

    if user == current_user
      current_items = current_user.items
      current_buy_orders = @database.buy_orders_by_user(current_user)

      haml :user_profile_own, :locals => {  :info => message,
                                            :user => current_user,
                                            :items_user => current_items,
                                            :buy_orders => current_buy_orders }
    else
      user_items = user.items

      haml :user_profile, :locals => {  :info => message,
                                        :current_user => current_user,
                                        :user => user,
                                        :items_user => user_items,
                                        :guest => current_user==nil }
    end
  end

end