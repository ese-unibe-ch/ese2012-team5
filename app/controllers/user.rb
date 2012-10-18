class User < Sinatra::Application
  before do
    @database = Marketplace::Database.instance
  end
  get "/user/:name" do

    username = params[:name]
    message = session[:message]
    session[:message] = nil
    user = @database.user_by_name(username)

    if username == session[:name]
      haml :user_profile_own, :locals => {  :user => user,
                                            :info => message,
                                            :items_user => @database.items_by_user(session[:name])}
    else
      haml :user_profile, :locals => {  :user => user,
                                        :current_user => @database.user_by_name(session[:name]),
                                        :items_user => @database.items_by_user(username),
                                        :info => message}
    end

  end

end