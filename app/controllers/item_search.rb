class Item_search

  before do
    @database = Marketplace::Database.instance
  end


  #TODO change method name and maybe model
  # Handle AJAX requests
  get '/search_item/:for' do
    query = params[:for]
    search_result = Marketplace::SearchResult.create(query)
    search_result.get

    current_user = @database.user_by_name(session[:name])

    found_items = search_result.found_items

    categories_found = Helper::Categorizer.categories_active_items_without(found_items, current_user) #@database.categories_given_without(found_items,current_user)
    categories_sorted_found = Helper::Categorizer.sort_categories_by_price(categories_found) #@database.sort_categories_by_price(categorized_found)


    haml :item_search, :layout => false, :locals => {:found_items => categories_sorted_found,
                                                     :current_user => current_user,
                                                     :description_map => search_result.description_map }
  end

end