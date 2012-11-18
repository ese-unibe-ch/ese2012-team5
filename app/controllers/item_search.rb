class Item_search

  before do
    @database = Marketplace::Database.instance
  end

  # Hand over search word
  get '/search_item' do

    query = params[:search_query]
    current_user = @database.user_by_name(session[:name])
    items = @database.categories_items_without(current_user)
    sorted_items = @database.sort_categories_by_price(items)


    haml :item_search, :locals => { :search_query => query,
                                    :items => items,
                                    :current_user => current_user,
                                    :categories => sorted_items}

  end


end