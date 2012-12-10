module Marketplace

  # AK: Few responsibilities, basically just storing data.
  # No documentation
  class Activity

    attr_accessor :type, :owner, :message, :time

    #AK style: align by the `||=`
    @USER_CREATED    ||= "User has been created"
    @USER_DEACTIVATE ||= "User's account has been deactivated"
    @USER_REACTIVATE ||= "User's account has been reactivated"
    @USER_SOLD_ITEM  ||= "User has sold an item"
    @USER_BOUGHT_ITEM||= "User has bought an item"

    @ITEM_ACTIVATE   ||= "Item has been activated"
    @ITEM_DEACTIVATE ||= "Item has been deactivated"
    @ITEM_SOLD       ||= "Item has been sold"
    @ITEM_CREATED    ||= "Item has been created"
    @ITEM_BOUGHT     ||= "Item has been bought"

    class << self
      attr_reader :USER_CREATED, :USER_DEACTIVATE, :USER_REACTIVATE, :USER_SOLD_ITEM, :USER_BOUGHT_ITEM
      attr_reader :ITEM_CREATED, :ITEM_ACTIVATE, :ITEM_DEACTIVATE, :ITEM_SOLD, :ITEM_BOUGHT
    end


    def self.create(type, owner, message)
      activity = self.new
      activity.type = type
      activity.owner = owner
      activity.message = message
      activity.time = Time.now
      owner.add_activity(activity)
      activity
    end

  end
end
