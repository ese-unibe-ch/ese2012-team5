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
      self.closest_string = ""
    end

    # Does the searching
    # A search_result object will only provide results after calling this method
    # @param [Array] items that can be found
    def find(items)
      query_array = query.gsub(/_/," ").downcase.split

      results = []
      items.each{ |item|
        match_all = true
        query_array.each{ |query|
          description = item.description.gsub("/,/","~")
          if !item.name.gsub(/_/," ").downcase.include?(query) and !description.gsub(/_/," ").downcase.include?(query)
            match_all = false
          else
            if description.gsub(/_/," ").downcase.include?(query)
              self.description_map[item] = map_description_part(description, query)
            else
              self.description_map[item] = if item.description.size>=30 then item.description[0..27] + "..." else item.description end
            end
          end
        }
        if match_all
          results.push(item)
        end
      }

      self.found_items = results
      if self.found_items.size == 0 and self.query.size >= 2
        suggest_other_query(items, query)
      end

    end

    # Selects the parts of description where query mathches to the items description
    # @param [String] description that needs to be parsed
    # @param [String] query that the user is looking for
    # @return [matching_description] created search_result
    def map_description_part(description, query)
      start_of_find = description.gsub(/_/, " ").downcase.index(query)
      substring_start = if start_of_find - 17 < 0 then 0 else start_of_find - 17  end
      substring_end = if start_of_find + 20 > description.size then description.size else start_of_find + 20 end

      matching_description = description[substring_start..substring_end].gsub("/~/", ",")

      if substring_end != description.size
        matching_description << "..."
      end

      if substring_start != 0
        matching_description = "..." + matching_description
      end

      matching_description
    end

    # Trys to find a similar query that would be successful
    # @param [Array] items that can be found
    # @param [String] query that the user is looking for
    def suggest_other_query(items, query)
      distance = 100
      word = ""

      items.each{ |item|
        name_array = item.name.downcase.split
        name_array.each{ |name_part|
          new_distance = Text::Levenshtein.distance(name_part.downcase , query.downcase)
          if new_distance < distance and name_part.length >= query.length
            word = item.name
            distance = new_distance
          end
        }
      }

      if distance < 3
        self.closest_string = word
      end

    end

  end

end
