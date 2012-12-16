module Marketplace

  #todo documentation why is this necessary

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