class Main < Sinatra::Application
  before do
    @database = Marketplace::Database.instance
  end
  get "/" do
    message = session[:message]
    session[:message] = nil
    if session[:name]
      #if logged in redirect to main
      haml :main, :locals => {:time => Time.now,
                              :user_items => @database.items_by_user(session[:name]),
                              :items => @database.sort_categorized_list_by_price,
                              :current_user => @database.user_by_name(session[:name])}
    else
      #if not redirect to mainguest
      haml :mainguest, :locals => { :time => Time.now,
                                    :users => @database.all_users,
                                    :items => @database.all_items,
                                    :info => message }
    end
  end
end
