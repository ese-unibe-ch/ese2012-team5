module Marketplace

  class Item  < Entity

    # Static variable
    # ID for a unique identification of each item
    @@id = 1

    attr_accessor :id, :name, :price, :owner, :active, :quantity, :pictures, :description, :description_log, :comments

    # Constructor that will automatic add new item to database
    # @param [String] name of the new item
    # @param [Float] price of the new item
    # @param [Integer] quantity of the new item
    # @param [User] owner of the new item
    # @return [Item] created item
    def self.create(name, description, price, quantity, owner)
      item = self.new
      item.name = name
      item.description = description
      item.price = price
      item.quantity = quantity
      item.owner = owner
      item.pictures = Array.new
      item.description_log = Array.new
      item.comments = Array.new
      time_now = Time.new
      item.add_description(time_now, item.description, price)
      Marketplace::Database.instance.add_item(item)
      Marketplace::Activity.create(Activity.ITEM_CREATED, item, "#{item.name} has been created by #{item.owner.name}")
      item
    end

    # Initial property of an item
    def initialize
      super
      self.id = @@id
      @@id += 1
      self.active = false
    end

    # Splits the item into two separate items
    # This item will have the rest quantity '(self.quantity - at)'
    # The new created items quantity will be 'at'
    # raise [NotImplementedError] if its not possible to split item at 'at'
    # @param [Integer] at index where to split the item
    # @return [Item] new item with quantity 'at'
    def split(at)
      if self.quantity < at
        raise NotImplementedError
      else
        rest = self.quantity - at
        self.quantity = rest
        item = Item.create(self.name, self.description, self.price, at, self.owner)
        item.active = true #NOTE by urs: do not use item.activate or you start the buyOrder listeners!
        item
      end
    end

    # Merges two similar items together
    # raise [NotImplementedError] if this and item are not mergeable
    def merge(item)
      if mergeable?(item)
        self.quantity = self.quantity + item.quantity
        item.delete
      else
        raise NotImplementedError
      end
    end

    # Checks if two items are similar
    # Similar means:
    # * same name
    # * same price
    # * but different objects
    def mergeable?(item)
      self.name == item.name and self.price == item.price and item != self
    end

    # Activates item and fires Item(=Event) to all buy_orders
    # @note If you don't want to fire the Event use "item.active = true" instead!
    def activate
      self.active = true
      Marketplace::Database.instance.call_buy_orders(self)
      Marketplace::Activity.create(Activity.ITEM_ACTIVATE, self, "#{self.name} has been activated")
    end

    def deactivate
      self.active = false
      Marketplace::Activity.create(Activity.ITEM_DEACTIVATE, self, "#{self.name} has been deactivated")
    end

    # Switches between active and inactive
    def switch_active
      if self.active
        self.deactivate
      else
        self.activate
      end
    end

    # Adds a new Array with the description and the price of the item into the description log array
    # Sets the actual description and price of the item with these new values
    # @param [Time] timestamp to add
    # @param [String] description to add
    # @param [Integer] price to add
    def add_description(timestamp, description, price)
      sub_array = [timestamp, description, price]
      self.description_log.push(sub_array)
      self.description = description
      self.price = price
    end

    # Returns the description from the description log, depending on the parameter timestamp
    # @param [Time] timestamp (key of the array)
    # @return [String] description to the timestamp
    def description_from_log(timestamp)
      sub_array = self.description_log.detect{ |sub_item_array| sub_item_array[0].to_s == timestamp.to_s }
      return sub_array[1]
    end

    # Returns the price from the description log, depending on the parameter timestamp
    # @param [Time] timestamp (key of the array)
    # @return [Integer] price to the timestamp
    def price_from_log(timestamp)
      sub_array = self.description_log.detect{ |sub_item_array| sub_item_array[0].to_s == timestamp.to_s }
      return sub_array[2]
    end

    # Deletes all entries in the description log, except the last one (used when an item was bought)
    # @return [Array] new array with one entry
    def clean_description_log
      array_temp = self.description_log.last
      self.description_log.clear
      self.description_log.push(array_temp)
    end

    # Compares the parameters with the description and price from the last entry in the log!
    # @param [String] description to compare
    # @param [Integer] price to compare
    def status_changed(description,price)
      description != self.description_log.last[1] || price != self.description_log.last[2]
    end

    # Adds a new comment into the comment array
    # @param [Time] timestamp to add
    # @param [String] comment to add
    # @param [User] user (author of the comment) to add
    def add_comment(timestamp, comment, user)
      username = user.name
      sub_array = [timestamp, comment, username]
      self.comments.push(sub_array)
      self.comments.sort! {|a,b| b[0] <=> a[0] }
    end

    # Delete entry with this timestamp
    # @param [Time] timestamp of the entry to delete
    def delete_comment(timestamp)
      sub_array = self.comments.detect{ |sub_item_array| sub_item_array[0].to_s == timestamp.to_s }
      self.comments.delete(sub_array)
    end

    # Deletes all entries in the comment array
    def clean_comments
      self.comments.clear
    end

    def add_image(url)
        self.pictures.push(url)
    end

    # Deletes image from pictures array and file
    # @param [Integer] position in pictures array
    def delete_image_at(position)
      filename = self.pictures.delete_at(position)
      ImageUploader.delete_image(filename, settings.root)
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
      self.pictures.each{ |image_url| ImageUploader.delete_image(image_url, settings.root) }
      Marketplace::Database.instance.call_users(self)
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