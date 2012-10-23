class Main < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get "/" do

    current_user = @database.user_by_name(session[:name])
    message = session[:message]
    session[:message] = nil

    if current_user
      current_items = current_user.items
      items = @database.categories_items_without(current_user)
      sorted_items = @database.sort_categories_by_price(items)

      haml :main, :locals => {  :info => message,
                                :current_items => current_items,
                                :current_user => current_user,
                                :categories => sorted_items }
    else
      items = @database.categories_items
      sorted_items = @database.sort_categories_by_price(items)

      haml :mainguest, :locals => { :info => message,
                                    :categories => sorted_items }
    end

  end

end
