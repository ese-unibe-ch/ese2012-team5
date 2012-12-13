module Marketplace

  class Activity

    attr_accessor :type, :owner, :message, :time

    # All possible types that an activity can have
    @USER_CREATED     ||= "/icons/user_created.png"
    @USER_DEACTIVATE  ||= "/icons/user_deactivate.png"
    @USER_REACTIVATE  ||= "/icons/user_reactivate.png"
    @USER_SOLD_ITEM   ||= "/icons/sold.png"
    @USER_BOUGHT_ITEM ||= "/icons/bought.png"
    @ITEM_ACTIVATE    ||= "/icons/item_activate.png"
    @ITEM_DEACTIVATE  ||= "/icons/item_deactivate.png"
    @ITEM_CREATED     ||= "/icons/item_created.png"
    @ITEM_SOLD        ||= "/icons/sold.png"
    @ITEM_BOUGHT      ||= "/icons/bought.png"

    class << self
      attr_reader :USER_CREATED, :USER_DEACTIVATE, :USER_REACTIVATE, :USER_SOLD_ITEM, :USER_BOUGHT_ITEM
      attr_reader :ITEM_CREATED, :ITEM_ACTIVATE, :ITEM_DEACTIVATE, :ITEM_SOLD, :ITEM_BOUGHT
    end

    # Constructor that will automatic add new activity to owner
    # @param [String] type of the new activity (directly used for icon at moment)
    # @param [Entity] owner of the new activity
    # @param [String] message of the new activity
    # @param [Time] time when activity was created
    # @return [Activity] created activity
    def self.create(type, owner, message)
      activity = self.new
      activity.type = type
      activity.owner = owner
      activity.message = message
      activity.time = Time.now
      owner.add_activity(activity)
      activity
    end

    def formated_time
      self.time.strftime("%Y-%m-%d %H:%M:%S")
    end

  end

end