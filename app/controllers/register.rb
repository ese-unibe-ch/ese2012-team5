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
    email = params[:email]

    validate_username(username, 3, 12)
    validate_password(password, password_conf, 4)
    validate_email(email)

    new_user = Marketplace::User.create(username, password, email)
    @database.add_user(new_user)

    send_verification_email(email)

    session[:message] = "#{new_user.name} created, now log in. Follow the link send to your email to verify your account."
    redirect '/login'
  end


  get '/verify_acc/:hash' do
    message = session[:message]
    session[:message] = nil
    hash = params[:hash]

    #check if hash exists
    if !(@database.hash_exists_in_ver_hashmap?(hash))
      session[:message] = "unknown link"
      redirect '/'
    else
      #activate user
      @database.get_user_from_ver_hashmap_by(hash).verify

      #delete user from verification hashmap
      @database.delete_entry_from_ver_hashmap(hash)
      session[:message] = "congratulations, your account is now activated"
      redirect '/'
    end
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

  #sends verification email
  # @param [String] email address
  # @param [String] username
  def send_verification_email(email)
    #hash generieren und in database speichern

    hash = SecureRandom.hex(24)
    user = @database.user_by_email(email)
    timestamp = Time.new
    @database.add_to_ver_hashmap(hash,user,timestamp)

    #verification mail senden
    Helper::Mailer.send_verification_mail_to(email, "Hi, #{user.name} \nfollow this link to verify your account.
        http://localhost:4567/verify_acc/#{hash}")

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

  #validates email input by user.
  def validate_email(email)
    if !(email =~ /[@]/)
      session[:message] = "email not valid"
      redirect '/register'
    end
    if !(email =~ /[.]/)
      session[:message] = "email not valid"
      redirect '/register'
    end
    if @database.all_emails.include?(email)
      session[:message] = "email already taken"
      redirect '/register'
    end
  end
end