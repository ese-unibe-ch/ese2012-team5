module Helper

  #class that helps validate user choices for password, username, email etc.
  class Checker

    @database = Marketplace::Database.instance

    def self.check_password?(user, input_password)
      proper_password = BCrypt::Password.new(user.password)
      if proper_password == input_password
        true
      else
        false
      end
    end

  end

end