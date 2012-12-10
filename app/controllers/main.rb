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
      categories = Helper::Categorizer.categories_all_active_items_without(current_user)
      sorted_categories = Helper::Categorizer.sort_categories_by_price(categories)

      haml :main, :locals => {  :info => message,
                                :current_items => current_items,
                                :current_user => current_user,
                                :categories => sorted_categories }
    else
      categories = Helper::Categorizer.categorize_all_active_items
      haml :mainguest, :locals => { :info => message,
                                    :categories => categories }
    end
  end

end
