class Register < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get '/register' do
    message = session[:message]
    session[:message] = nil
    haml :register, :locals => { :info => message}
  end

  post '/register' do

    username = params[:username]
    password = params[:password]
    password_conf = params[:password_conf]

    validate_username(username, 3, 12)
    validate_password(password, password_conf, 4)

    new_user = Marketplace::User.create(username, password,email)
    @database.add_user(new_user)

    session[:message] = "#{new_user.name} created, now log in"
    redirect '/login'
  end

  #checks if username is already in use and if length of username is within the given limits
  # @param [String] username name to check
  # @param [Integer] min minimal length username must have
  # @param [Integer] max maximal length username can have
  def validate_username(username, min, max)
    if @database.user_by_name(username)
      session[:message] = "username already taken"
      redirect '/register'
    end
    if username.length<3
      session[:message] = "username too short"
      redirect '/register'
    end
    if username.length>12
      session[:message] = "username too long"
      redirect '/register'
    end
  end

  #validates password input by user.
  # @param [String] password user chooses
  # @param [String] password_conf password confirmation
  # @param [Integer] length minimal length in characters password must have
  def validate_password(password, password_conf, length)
    if password != password_conf
      session[:message] = "password and confirmation don't match"
      redirect '/register'
    end
    if password.length<length
      session[:message] = "password too short"
      redirect '/register'
    end
    if !(password =~ /[0-9]/)
      session[:message] = "no number in password"
      redirect '/register'
    end
    if !(password =~ /[A-Z]/)
      session[:message] = "no uppercase letter in password"
      redirect '/register'
    end
    if !(password =~ /[a-z]/)
      session[:message] = "no lowercase letter in password"
      redirect '/register'
    end
  end

  def validate_reset_password(password, password_conf, length)
    if password != password_conf
      session[:message] = "password and confirmation don't match"
      redirect '/rset_password'
    end
    if password.length<length
      session[:message] = "password too short"
      redirect '/rset_password'
    end
    if !(password =~ /[0-9]/)
      session[:message] = "no number in password"
      redirect '/rset_password'
    end
    if !(password =~ /[A-Z]/)
      session[:message] = "no uppercase letter in password"
      redirect '/rset_password'
    end
    if !(password =~ /[a-z]/)
      session[:message] = "no lowercase letter in password"
      redirect '/rset_password'
    end
  end

  #validates email input by user.
  def validate_email(email, email_conf)
    if email != email_conf
      session[:message] = "email and confirmation don't match"
      redirect '/register'
    end
    if !(email =~ /[@]/)
      session[:message] = "email not valid"
      redirect '/register'
    end
    if !(email =~ /[.]/)
      session[:message] = "email not valid"
      redirect '/register'
    end
  end

end