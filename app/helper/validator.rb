# Module that takes care of validating input data and producing error messages if input data does not match criteria.
module Validator

  @database = Marketplace::Database.instance

  # Final static variables that declare min and max length of certain user chosen words.
  @@MIN_USERNAME_LENGTH = 3
  @@MAX_USERNAME_LENGTH = 12
  @@MIN_PASSWORD_LENGTH = 4

  # Checks if username is already in use and if length of username is within the given limits
  # @param [String] username name to check
  # @param [Integer] min minimal length username must have
  # @param [Integer] max maximal length username can have
  def self.validate_username(username)
    return "~error~username already taken." if @database.user_by_name(username) || @database.deactivated_user_by_name(username)
    return "~error~username too short." if username.length < @@MIN_USERNAME_LENGTH
    return "~error~username too long." if username.length > @@MAX_USERNAME_LENGTH
    return ""
  end

  # Validates password input by user.
  # @param [String] password user chooses
  # @param [String] password_conf password confirmation
  # @param [Integer] length minimal length in characters password must have
  def self.validate_password(password, password_conf)
    return "~error~password and confirmation don't match!" unless password == password_conf
    return "~error~password too short!" if password.length < @@MIN_PASSWORD_LENGTH
    return "~error~no number in password!" unless (password =~ /[0-9]/)
    return "~error~no uppercase letter in password!" unless (password =~ /[A-Z]/)
    return "~error~no lowercase letter in password!" unless (password =~ /[a-z]/)
    return ""
  end

  # Validates email input by user.
  # @param [String] email to control
  def self.validate_email(email)
    return "~error~email not valid!" unless (email =~ /[@]/) or  (email =~ /[.]/)
    return "~error~email already taken!" if @database.all_emails.include?(email)
    return ""
  end

  # Validates string input by user.
  # @param [Integer] integer to control
  def self.validate_integer(integer, declaration, min, max)
    begin
      !(Integer(integer))
    rescue ArgumentError
      return "~error~#{declaration} was not a number!"
    end
    return "~error~#{declaration} was smaller than minimum #{min.to_i}!" if min != nil and integer.to_i < min.to_i
    return "~error~#{declaration} was bigger than maximum #{max.to_i}!" if max != nil and integer.to_i > max.to_i
    return ""
  end

  # Validates string input by user.
  # @param [String] string to control
  # @param [String] declaration that will be showed in error message
  def self.validate_string(string, declaration)
    return "~error~#{declaration} was empty!" if string == "" or string.strip == "" or string.nil?
    return ""
  end

  # Validates a user.
  # @param [User] user to control
  def self.validate_user(user)
    return "~error~user doesn't exist!" if user.nil?
    return "~error~your account isn't verified.~error~You must first click on the link in the email received right after registration before you can log in." if !user.verified
    return ""
  end

end
