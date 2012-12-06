module Helper

  class Checker

    def self.check_password?(user, input_password)
      proper_password = BCrypt::Password.new(user.password)
      proper_password == input_password
    end

  end

end