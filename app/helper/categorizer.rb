module Helper

  class Categorizer

    @database = Marketplace::Database.instance


    # Categories all ACTIVE items by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def self.categories_all_active_items
      items = @database.all_active_items
      categories_items(items)
    end

    # Categories all given ACTIVE items by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def self.categories_active_items(items)
      items.select{ |item| item.active }
      categories_items(items)
    end

    # Categories all ACTIVE items without items of user by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def self.categories_all_active_items_without(user)
      items = @database.all_active_items.select{ |item| item.owner != user }
      categories_items(items)
    end

    # Categories all given ACTIVE items without items of user by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def self.categories_active_items_without(items,user)
      items.select{ |item| item.owner != user }
      categories_items(items)
    end

    # Categories all given items by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def categories_items(items)
      categorized_items = Array.new

      items.each{ |item|
        sub_array = categorized_items.detect{ |sub_item_array| sub_item_array[0].name == item.name }
        if sub_array != nil
          sub_array.push(item)
        else
          new_sub_array = Array.new
          new_sub_array.push(item)
          categorized_items.push(new_sub_array)
        end
      }
      categorized_items
    end




    # Selects the category with desired name
    def select_category_with_name(name, categories)
      categories.detect{ |sub_item_array| sub_item_array[0].name == name }
    end

    # Sorts a categorized_item list by the price
    # @return [Array of Arrays] sorted array with arrays for every different item.name
    def self.sort_categories_by_price(categories)
      sorted_categories = Array.new
      categories.each{ |sub_array|
        if sub_array.size > 1
          sorted_categories.push(sort_category_by_price(sub_array))
        else
          sorted_categories.push(sub_array)
        end
      }
      sorted_categories
    end

    # Sorts a category (its items) by their price (hardcoded descending)
    def self.sort_category_by_price(category)
      category.sort! {|a,b| a.price <=> b.price}
    end

  end

end