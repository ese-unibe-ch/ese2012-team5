module Helper

  #helps validate user choices for password, username, email etc.
  class Validator

    @database = Marketplace::Database.instance

    #checks if username is already in use and if length of username is within the given limits
    # @param [String] username name to check
    # @param [Integer] min minimal length username must have
    # @param [Integer] max maximal length username can have
    def self.validate_username(username, min, max)
      if @database.user_by_name(username) || @database.get_deactivated_user_by_name(username)
        return "error ~ username already taken. "
      end
      if username.length<min
        return "error ~ username too short. "
      end
      if username.length>max
        return "error ~ username too long. "
      end
      return ""
    end

    #validates password input by user.
    # @param [String] password user chooses
    # @param [String] password_conf password confirmation
    # @param [Integer] length minimal length in characters password must have
    def self.validate_password(password, password_conf, length)
      if password != password_conf
        return "error ~ password and confirmation don't match. "
      end
      if password.length<length
        return "error ~ password too short. "
      end
      if !(password =~ /[0-9]/)
        return "error ~ no number in password. "
      end
      if !(password =~ /[A-Z]/)
        return "error ~ no uppercase letter in password. "
      end
      if !(password =~ /[a-z]/)
        return "error ~ no lowercase letter in password. "
      end
      return ""
    end

    #validates email input by user.
    def self.validate_email(email)
      if !(email =~ /[@]/) or  !(email =~ /[.]/)
        return "error ~ email not valid. "
      end
      if @database.all_emails.include?(email)
        return "error ~ email already taken. "
      end
      return ""
    end

  end
end
