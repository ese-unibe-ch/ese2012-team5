class User < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get "/user/:name" do

    current_user = @database.user_by_name(session[:name])
    current_items = current_user.items
    user = @database.user_by_name(params[:name])
    user_items = user.items


    message = session[:message]
    session[:message] = nil
    if user == current_user
      haml :user_profile_own, :locals => {  :info => message,
                                            :user => current_user,
                                            :items_user => current_items }
    else
      haml :user_profile, :locals => {  :info => message,
                                        :current_user => current_user,
                                        :user => user,
                                        :items_user => user_items }
    end

  end

end