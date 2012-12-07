module Marketplace

  class SearchResult

    attr_accessor :query, :found_items, :description_map ,:closest_string

    # Constructor for search_result
    # @param [String] query that was entered
    # @return [search_result] created search_result
    def self.create(query)
      search_result = self.new
      search_result.query = query
      search_result
    end

    # Initial property of an search_result
    def initialize
      self.description_map = Hash.new
      self.found_items = []
      self.closest_string=""
    end

    # Does the search
    def get
      query_array = query.gsub(/_/," ").downcase.split
      active_items = Marketplace::Database.instance.all_active_items
      found_by_name = []
      found_by_description = []

      query_array.each{|query|
        active_items.each { |item|
          if item.name.gsub(/_/," ").downcase.include?(query)
            found_by_name.push(item)
            self.description_map[item]=if item.description.size>=30 then item.description[0..27]+"..." else item.description end
          end
        }

        active_items.each { |item|
          desc = item.description.gsub("/,/","~")

          if desc.gsub(/_/," ").downcase.include?(query)
            found_by_description.push(item)
            map_description_part(desc, item, query)

          end
        }
      }
      self.found_items = found_by_name | found_by_description

      if self.found_items.size == 0 && self.query.size >= 2
        get_closest_item_name_to(query)
      end


    end

    #maps the parts of description where query mathches to the item
    def map_description_part(desc, item, query)
      start_of_find = desc.gsub(/_/, " ").downcase.index(query)
      substring_start = if start_of_find-17<0 then 0 else start_of_find-17  end
      substring_end = if start_of_find+20>desc.size then desc.size else start_of_find+20 end

      search_desc = desc[substring_start..substring_end].gsub("/~/", ",")

      if substring_end != desc.size
        search_desc << "..."
      end

      if substring_start != 0
        search_desc = "..."+search_desc
      end

      self.description_map[item]= search_desc
    end

    #updates closest string
    def get_closest_item_name_to(query)
      all_active_items = Marketplace::Database.instance.all_active_items
      distance = 100
        all_active_items.each{|item|
          name_array= item.name.downcase.split
          name_array.each{|name_part|
            new_distance = Text::Levenshtein.distance(name_part.downcase,query.downcase)
            if new_distance < distance
              self.closest_string = item.name
              distance = new_distance
            end
        }}
    end
  end
end
