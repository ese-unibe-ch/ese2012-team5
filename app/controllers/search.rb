class Search

  before do
    @database = Marketplace::Database.instance
  end


  #TODO change method name and maybe model
  # Handle AJAX requests
  get '/search/:for' do
    current_user = @database.user_by_name(session[:name])
    query = params[:for]

    redirect '/login' if current_user.nil?


    search_result = Marketplace::SearchResult.create(query)
    search_result.get

    current_user = @database.user_by_name(session[:name])

    found_items = search_result.found_items

    categories_found = Helper::Categorizer.categories_active_items_without(found_items, current_user)
    categories_sorted_found = Helper::Categorizer.sort_categories_by_price(categories_found)


    haml :search, :layout => false, :locals => { :query => query,
                                                 :found_items => categories_sorted_found,
                                                 :current_user => current_user,
                                                 :description_map => search_result.description_map,
                                                 :closest_string => search_result.closest_string }
  end

end