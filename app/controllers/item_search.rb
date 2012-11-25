class Item_search

  before do
    @database = Marketplace::Database.instance
  end

  # Handle AJAX requests

  get '/search_item/:for' do

    query = params[:for].gsub(/_/," ").downcase


    current_user = @database.user_by_name(session[:name])
    active_items = @database.all_active_items
    found_by_name = []
    found_by_description = []

    active_items.each { |item|
      if item.name.downcase.include?(query)
        found_by_name.push(item)
      end
    }

    active_items.each { |item|
      if item.description.downcase.include?(query)
        found_by_description.push(item)

        desc = item.description
        start_of_find = desc.index(query)
        substring_start = start_of_find-12<0 ? 0 : start_of_find-12
        substring_end = start_of_find+15>desc.length ? desc.size : start_of_find+15

        item.description_search = desc[substring_start..substring_end]

        if substring_end != desc.size
          item.description_search << "..."
        end

        if substring_start != 0
          item.description_search = "..."+item.description_search
        end

      end
    }

    found_items = found_by_name | found_by_description


    categorized_found = @database.categories_given_without(found_items,current_user)
    categorized_sorted_found = @database.sort_categories_by_price(categorized_found)


    haml :item_search,:layout => false ,
         :locals => {  :found_items => categorized_sorted_found,
                       :current_user => current_user,
         }


  end


end