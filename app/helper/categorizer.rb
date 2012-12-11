module Categorizer

  @database = Marketplace::Database.instance


  # Categorizes all ACTIVE items by their name
  # @return [Array of Categories] array with categories for every different item.name
  def self.categorize_all_active_items
    items = @database.all_active_items
    categorize_items(items)
  end

  # Categorizes all given ACTIVE items by their name
  # @return [Array of Categories] array with categories for every different item.name
  def self.categories_active_items(items)
    items.select{ |item| item.active }
    categorize_items(items)
  end

  # Categorizes all ACTIVE items without items of user by their name
  # @return [Array of Categories] array with categories for every different item.name
  def self.categorize_all_active_items_without(user)
    items = @database.all_active_items.select{ |item| item.owner != user }
    categorize_items(items)
  end

  # Categorizes all given ACTIVE items without items of user by their name
  # @return [Array of Categories] array with categories for every different item.name
  def self.categorize_active_items_without(items, user)
    items.select{ |item| item.owner != user }
    categorize_items(items)
  end


  # Categorizes all given items by their name
  # @return [Array of Categories] array with categories for every different item.name
  def self.categorize_items(items)
    categories = Array.new
    categories if items.nil? or items.empty?
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
  # @return [Category] Category that fits the name
  def self.category_by_name(category_name)
    categories = categorize_all_active_items
    if !categories.nil?
      categories.detect{ |category| category.name == category_name }
    end
  end

  # Detects category minus any item of given user by name from a list of categories
  # @return [Category] category that fits the name minus all items of user
  def self.category_by_name_without(category_name, user)
    categories = categorize_all_active_items_without(user)
    if !categories.nil?
      categories.detect{ |category| category.name == category_name }
    end
  end


  # Detects the category with the desired name from the categories
  # @return [Category] category that fits the name
  def self.select_category_by_name(category_name, categories)
    categories.detect{ |category| category.name == category_name }
  end

  # Sorts an array of categories by the price
  # @return [Array of Categories] sorted array of categories for every different item.name
  def self.sort_categories_by_price(categories)
    sorted_categories = Array.new
    return sorted_categories if categories.nil? or categories.empty?

    categories.each{ |category|
      if category.items.size > 1
        sorted_categories.push(sort_category_by_price(category))
      else
        sorted_categories.push(category)
      end
    }
    sorted_categories
  end

  # Sorts a category (its items) by their price (hardcoded descending)
  def self.sort_category_by_price(category)
    category.items.sort! {|a,b| a.price <=> b.price}
  end

end