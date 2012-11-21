module Helper

  #helps validate user choices for password, username, email etc.
  class Validator

    @database = Marketplace::Database.instance

    #checks if username is already in use and if length of username is within the given limits
    # @param [String] username name to check
    # @param [Integer] min minimal length username must have
    # @param [Integer] max maximal length username can have
    def self.validate_username(username, min, max)
      return "error ~ username already taken. " if @database.user_by_name(username) || @database.deactivated_user_by_name(username)
      return "error ~ username too short. " if username.length<min
      return "error ~ username too long. " if username.length>max
      return ""
    end

    #validates password input by user.
    # @param [String] password user chooses
    # @param [String] password_conf password confirmation
    # @param [Integer] length minimal length in characters password must have
    def self.validate_password(password, password_conf, length)
      return "error ~ password and confirmation don't match. " unless password == password_conf
      return "error ~ password too short. " if password.length<length
      return "error ~ no number in password. " unless (password =~ /[0-9]/)
      return "error ~ no uppercase letter in password. " unless (password =~ /[A-Z]/)
      return "error ~ no lowercase letter in password. " unless (password =~ /[a-z]/)
      return ""
    end

    #validates email input by user.
    def self.validate_email(email)
      return "error ~ email not valid. " unless (email =~ /[@]/) or  (email =~ /[.]/)
      return "error ~ email already taken. " if @database.all_emails.include?(email)
      return ""
    end

  end
end
