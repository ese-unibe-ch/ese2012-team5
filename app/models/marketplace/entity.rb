class Entity

  attr_accessor :activities


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