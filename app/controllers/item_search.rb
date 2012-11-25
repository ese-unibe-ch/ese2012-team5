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
      desc = item.description.gsub("/,/","_")

      if desc.downcase.include?(query)
        found_by_description.push(item)

        start_of_find = desc.index(query)
        substring_start = if start_of_find-17<0 then 0 else start_of_find-17 end
        substring_end = if start_of_find+20>desc.size then desc.size else start_of_find+20 end

        item.description_search = desc[substring_start..substring_end].gsub("/_/",",")

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