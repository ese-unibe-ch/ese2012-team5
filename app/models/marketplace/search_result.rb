module Marketplace
  class SearchResult

    attr_accessor :query, :found_items, :description_map

    # @return [Search_result] created Search
    def self.create(query)
      search_result = self.new
      search_result.query = query
      search_result
    end

    def initialize
      self.description_map = Hash.new
      self.found_items = []
    end

    #Does the search
    #
    # AK this methods needs a face lift. it's too long, too nested and has mvc
    # problems.
    def get
      query_array = query.gsub(/_/," ").downcase.split
      active_items = Marketplace::Database.instance.all_active_items
      found_by_name = []
      found_by_description = []

      # AK write out the algorithm in natural language and then translate it
      # into code.
      #
      # E.g.
      # For every item, put it in the returned array if it matches by the name or the description.
      #
      # This way, you can see, how the method can be split, how it should be
      # structured and often it even gives better run-times.
      query_array.each{|query|
        active_items.each { |item|
          if item.name.gsub(/_/," ").downcase.include?(query)
            found_by_name.push(item)
            self.description_map[item]=if item.description.size>=30 then item.description[0..27]+"..." else item.description end # AK first of all, this is not very readable, second of all, this is view stuff and thus a MVC breach.
          end
        }

        active_items.each { |item|
          desc = item.description.gsub("/,/","~") # AK why?

          if desc.gsub(/_/," ").downcase.include?(query)
            found_by_description.push(item)

            start_of_find = desc.gsub(/_/," ").downcase.index(query)
            substring_start = if start_of_find-17<0 then 0 else start_of_find-17 end
            substring_end = if start_of_find+20>desc.size then desc.size else start_of_find+20 end

            search_desc = desc[substring_start..substring_end].gsub("/~/",",")

            if substring_end != desc.size
              search_desc << "..."
            end

            if substring_start != 0
              search_desc = "..."+search_desc
            end

            self.description_map[item]= search_desc

          end
        }
      }
      self.found_items = found_by_name | found_by_description

    end
  end
end
