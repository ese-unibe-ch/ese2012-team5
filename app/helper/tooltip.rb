module Tooltip

  # A Helper class that provides html coder for the tooltip in the views

  def self.owner_tooltip_of(category)
    owner_tooltip=""
    category.owners.each { |owner|
      owner_tooltip += "<a href=\"/user/"+owner.name+"\" >" +owner.name + "</a><br/> "
    }
    owner_tooltip
  end

  def self.items_tooltip_of(category)
    items_tooltip=""
    category.items.each { |item|
      items_tooltip += "<a href=\"/item/" + item.id.to_s + "\" >" + item.quantity.to_s + "x for " + item.price.to_s + " credits from "+item.owner.name+ "</a><br/> "
    }
    items_tooltip
  end
end