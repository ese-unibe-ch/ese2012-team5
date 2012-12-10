module Helper

  class Categorizer

    @database = Marketplace::Database.instance


    # Categorizes all ACTIVE items by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def self.categorize_all_active_items
      items = @database.all_active_items
      categorize_items(items)
    end

    # Categorizes all given ACTIVE items by their name
    # @return [Array of Arrays] array with arrays for every different item.name
    def self.categories_active_items(items)
      items.select{ |item| item.active }
      categories_items(items)
    end

    # Categorizes all ACTIVE items without items of user by their name
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
    def self.categorize_items(items)
      categories = Array.new
      #   return categorized_items if items.nil? or items.empty?
      items.each{ |item|
        category = categories.detect{ |category| category.name == item.name }
        if category != nil
          category.add(item)
        else
          categories.push(Marketplace::Category.create(item))
        end
      }
      categories
    end

    # Detects category by name from a list of categories
    # @return [Array] array with items that fit the category
    def self.category_by_name(category_name)
      items = categories_all_active_items
      if !items.nil? and !items.empty?
        items.detect{ |category| category[0].name == category_name }
      end
    end

    # Detects category by name from a list of categories without any item of given user
    # @return [Array] array with items that fit the category and don't belong to given user
    def self.category_by_name_without(category_name, user)
      items = category_by_name(category_name)
      if !items.nil? and !items.empty?
        items.select{ |item| item.owner != user }
      end
    end


    # Detects the category with the desired name from the categories
    def self.select_category_by_name(category, categories)
      categories.detect{ |sub_item_array| sub_item_array[0].name == category }
    end

    # Sorts a categorized_item list by the price
    # @return [Array of Arrays] sorted array with arrays for every different item.name
    def self.sort_categories_by_price(categories)
      sorted_categories = Array.new

      return sorted_categories if categories.nil? or categories.empty?

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