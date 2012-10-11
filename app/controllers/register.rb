class Register < Sinatra::Application

  get '/register' do
    message = session[:message]
    session[:message] = nil
    haml :register, :locals => { :info => message}
  end

  post '/register' do
    username = params[:username]
    password = params[:password]
    password_conf = params[:password_conf]

    if username_taken?(username)
      session[:message] = "username already in use"
      redirect '/register'
    end

    validate(password, password_conf, 4)

    new_user = Marketplace::User.create(username, password)
    new_user.save()

    session[:message] = "#{new_user.name} created, now log in"
    redirect '/login'
  end

  #checks if username is already in use
  # @param [String] username name to check
  def username_taken?(username)
    nil != Marketplace::User.by_name(username)
  end

  #validates password input by user.
  # @param [String] password user chooses
  # @param [String] password_conf password confirmation
  # @param [Integer] length minimal length in characters password must have
  def validate(password, password_conf, length)
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

end