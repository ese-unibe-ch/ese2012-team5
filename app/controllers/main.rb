class Main < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get "/" do

    current_user = @database.user_by_name(session[:name])
    current_items = @database.items_by_user(session[:name])
    categorized_items = @database.categories_items
    sorted_categorized_items = @database.sort_by_price(categorized_items)

    message = session[:message]
    session[:message] = nil


    if session[:name]
      haml :main, :locals => {  :info => message,
                                :current_items => current_items,
                                :current_user => current_user,
                                :categories => sorted_categorized_items }
    else
      haml :mainguest, :locals => { :info => message,
                                    :categories => sorted_categorized_items }
    end

  end

end
