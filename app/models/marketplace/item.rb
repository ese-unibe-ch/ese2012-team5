module Marketplace

  class Item

    # Static variable
    # ID for a unique identification of each item
    @@id = 1

    attr_accessor :id, :name, :price, :owner, :active, :quantity, :pictures, :description, :description_log

    # Constructor that will automatic add new item to database
    # @param [String] name of the new item
    # @param [Float] price of the new item
    # @param [Integer] quantity of the new item
    # @param [User] owner of the new item
    # @return [Item] created item
    def self.create(name, price, quantity, owner)
      item = self.new
      item.name = name
      item.price = price
      item.quantity = quantity
      item.owner = owner
      item.pictures = Array.new
      item.description_log = Array.new
      time_now = Time.new
      item.add_description(time_now, item.description, price)
      Marketplace::Database.instance.add_item(item)
      item
    end

    # Initial property of an item
    def initialize
      self.id = @@id
      @@id += 1
      self.active = false
      self.description = "No description table fridge house lord who is the red fidge lots of stuff long table fridge red biiig message test this rings"
    end

    # Splits the item into two separate items
    # This item will have quantity (self.quantity - at)
    # @param [Integer] at index where to split the item
    # @return [Item] new item with quantity 'at'
    def split(at)
      if self.quantity < at
        throw NotImplementedError
      else
        rest = self.quantity - at
        self.quantity = rest
        item = Item.create(self.name, self.price, at, self.owner)
        item.active = true #NOTE by urs: do not use item.activate or you start the buyOrder listeners!
        item
      end
    end

    # Merges two similar items together
    # [NotImplementedError] if this and item are not mergeable
    def merge(item)
      if mergeable?(item)
        self.quantity = self.quantity + item.quantity
        item.delete
      else
        throw NotImplementedError
      end
    end

    # Checks if two items are similar
    # Similar means:
    # *same name
    # *same price
    # *but different objects
    def mergeable?(item)
      self.name == item.name and self.price == item.price and item != self
    end

    # Activates item and fires Item(=Event) to all buy_orders
    # @note If you don't want to fire the Event use "item.active = true" instead!
    def activate
      self.active = true
      Marketplace::Database.instance.call_buy_orders(self)
    end

    def deactivate
      self.active = false
    end

    # Switches between active and inactive
    def switch_active
      if self.active
        self.deactivate
      else
        self.activate
      end
    end

    def add_description(timestamp, description, price)
      sub_array = [timestamp, description, price]
      self.description_log.push(sub_array)
    end

    def get_description_from_log(timestamp)
      description = ""
      self.description_log.each{ |sub_array|
        if sub_array[0] = timestamp
          description = sub_array[1]
        end
      }
      return description
    end

    def get_price_from_log(timestamp)
      price = 0
      self.description_log.each{ |sub_array|
        if sub_array[0] = timestamp
          price = sub_array[2]
        end
      }
      return price
    end

    # Deletes description from description log array
    # @param [Time] Timestamp of the entry to delete
    def delete_description_at(timestamp)
      self.description_log.each{ |sub_array|
        if sub_array[0] == timestamp
          self.description_log.delete(sub_array)
        end
      }
    end

    def get_status_changed(description,price)
      description != self.description_log.last[1] || price != self.description_log.last[2]
    end

    def add_image(url)
        self.pictures.push(url)
    end

    # Deletes image from pictures array and file
    # @param [Integer] position in pictures array
    def delete_image_at(position)
      filename = self.pictures.delete_at(position)
      Helper::ImageUploader.delete_image(filename, settings.root)
      self.pictures.reject{ |c| c.empty? }
    end

    # Selects the image at 'position' in pictures as front image
    # The front image is at position 0 in pictures
    # @param [Integer] position in pictures array
    def select_front_image(position)
      old_front_image = self.pictures.at(0)
      self.pictures[0] = self.pictures[position]
      self.pictures[position] = old_front_image
    end

    # Deletes the item and all its profile pictures
    def delete
      self.pictures.each{ |image_url| Helper::ImageUploader.delete_image(image_url, settings.root) }
      Marketplace::Database.instance.delete_item(self)
    end

    def to_s
      "Name: #{name} Price:#{self.price} Quantity:#{self.quantity} Active:#{self.active} Owner:#{self.owner.name}"
    end

    # @param [Integer] index of image in pictures array
    # @return [String] path of item profile picture at 'index'
    def image_path(index)
      if self.pictures[index] == nil
        return File.join("", "images", "default_item.jpg")
      else
        return File.join("", "images", self.pictures[index])
      end
    end

  end

end