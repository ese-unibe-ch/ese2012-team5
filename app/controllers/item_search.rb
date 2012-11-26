class Item_search

  before do
    @database = Marketplace::Database.instance
  end

  # Handle AJAX requests

  get '/search_item/:for' do

    query_array = params[:for].gsub(/_/," ").downcase.split


    current_user = @database.user_by_name(session[:name])
    active_items = @database.all_active_items

    found_hash = Hash.new(0)

    query_array.each{|query|

      #add items with find in name
      active_items.each { |item|
        if item.name.gsub(/_/," ").downcase.include?(query)
          name_temp = item.name.delete(query)

          if(!found_hash.has_key?(item))
            add_relevance =  (item.name.size - name_temp.size)/(query.size)*2
            found_hash[item] += add_relevance
          else
            found_hash[item]
            add_relevance =  (item.name.size - name_temp.size)/(query.size)*2
            found_hash[item] += add_relevance
          end
        end
      }

      #add items with find in description

      active_items.each { |item|
        desc = item.description.gsub("/,/","~")
        desc_temp = desc.delete(query)

        if desc.gsub(/_/," ").downcase.include?(query)

          add_relevance =  (desc.size - desc_temp.size)/(query.size)
          found_hash[item] += add_relevance

          start_of_find = desc.gsub(/_/," ").downcase.index(query)
          substring_start = if start_of_find-17<0 then 0 else start_of_find-17 end
          substring_end = if start_of_find+20>desc.size then desc.size else start_of_find+20 end

          item.description_search = desc[substring_start..substring_end].gsub("/~/",",")

          if substring_end != desc.size
            item.description_search << "..."
          end

          if substring_start != 0
            item.description_search = "..."+item.description_search
          end

        end
      }
    }

    found_items =[]
    helper_factor2 = 0
    found_hash.each_value{|value| helper_factor2+=value}

    if(!found_hash.empty?)

      found_hash.sort_by{|item, count| count}

      #Calculate first factor between 0-1 and Helper for second factor

      factor1=Rational(1,(found_hash.size))

      found_hash.each_key{|item|
        #Second and final factor
        if helper_factor2 == 0 then helper_factor2 = 10 end
        factor2 = Rational(found_hash[item],helper_factor2)
        final_factor= if factor1+factor2>1 then 1 else factor1+factor2 end

        puts item.name
        found_hash[item]
        item.search_relevance = (final_factor.to_f * 100).round()
        found_items.push(item)
        }
    end

    if(found_items.size>1)
      found_items.each{ |item1|
       count_same_name = found_items.select{|item2| item2.name.include?(item1.name)}.size
       item1.search_relevance *= count_same_name
       item1.search_relevance = if item1.search_relevance>100 then 100 else item1.search_relevance end
    }

     found_items.sort!{|a,b| a.search_relevance <=> b.search_relevance}
    end

    categorized_found = @database.categories_given_without(found_items,current_user)
    categorized_sorted_found = @database.sort_categories_by_price(categorized_found).reverse!



    haml :item_search,:layout => false ,
         :locals => {  :found_items => categorized_sorted_found,
                       :current_user => current_user,
         }


  end


end