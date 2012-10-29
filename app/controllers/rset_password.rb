class RsetPassword < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get '/forgot_password' do
    message = session[:message]
    session[:message] = nil
    haml :forgot_password, :locals => { :info => message}
  end

  post '/forgot_password' do

    email = params[:email]

    if (!email_exists?(email))
      session[:message] = "email not registered"
      redirect '/forgot_password'
    end

    #hash(24 stellig, hex) und timestamp generieren/in map speichern

    hash = SecureRandom.hex(24)
    user = @database.user_by_email(email)
    timestamp = Time.new

    # 24 stunden addieren => 86400 sekunden
    valid_until = timestamp + 86400

    @database.add_to_hashmap(hash,user,timestamp)

    #mail senden
    Helper::Mailer.send_pw_reset_mail_to(email, "Hi, \nfollow this link to reset your password.
      http://localhost:4567/rset_password/#{hash}\nThis link is valid until #{valid_until}" )

    session[:message] = "please check your mails for reset-link "
    redirect '/login'
  end

  get '/rset_password/:hash' do
    message = session[:message]
    session[:message] = nil

    #delete entries older than 24h
    @database.delete_24h_old_entries

    #check if hash exists
    if !(@database.hash_exists_in_map?(params[:hash]))
      session[:message] = "unknown/timed out link please request a new one"
      redirect '/login'
    end

    haml :user_rset_password, :locals => { :info => message,
                                           :hash => params[:hash]}
  end

  post '/rset_password/:hash' do

    password = params[:password]
    password_conf = params[:password_conf]
    hash = params[:hash]

    validate_reset_password(password, password_conf, 4, hash)

    #check for which user has that hash
    user = @database.get_user_by_hash(hash)
    user.change_password(password)
    @database.delete_hashentry(hash)

    session[:message] = "password changed, now log in"
    redirect '/login'
  end



  def validate_reset_password(password, password_conf, length, hash)
    if password != password_conf
      session[:message] = "password and confirmation don't match"
      puts(hash)
      puts("dini mueter")
      redirect "/rset_password/#{hash}"
    end
    if password.length<length
      session[:message] = "password too short"
      redirect "/rset_password/#{hash}"
    end
    if !(password =~ /[0-9]/)
      session[:message] = "no number in password"
      redirect "/rset_password/#{hash}"
    end
    if !(password =~ /[A-Z]/)
      session[:message] = "no uppercase letter in password"
      redirect "/rset_password/#{hash}"
    end
    if !(password =~ /[a-z]/)
      session[:message] = "no lowercase letter in password"
      redirect "/rset_password/#{hash}"
    end
  end

  def email_exists?(mail)
   emails = @database.all_emails()
   emails.include?(mail)
  end
end
