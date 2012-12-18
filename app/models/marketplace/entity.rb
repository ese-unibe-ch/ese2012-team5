module Marketplace

  # This class acts like an abstract class that the user and the item class implement.
  # Users and Items are both entities. Entities store all their activities.
  class Entity

    attr_accessor :activities

    # Initial property of a entity
    def initialize
      self.activities = Array.new
    end

    def add_activity(activity)
      activities << activity
    end

    def delete_activity(activity)
      activities.delete(activity)
    end

  end

end