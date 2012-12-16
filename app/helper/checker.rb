module Checker

  def self.check_password?(user, input_password)
    proper_password = BCrypt::Password.new(user.password)
    proper_password == input_password
  end

  # Create a hash-table
  # key is the 'item.id'
  # value is the 'quantity' to buy
  def self.create_buy_map(params)
    x = 0
    map = Hash.new
    while params.key?("id#{x}")
      if params["quantity#{x}"].to_i != 0
        map[params["id#{x}"]] = params["quantity#{x}"].to_i
      end
      x += 1
    end
    map
  end
end