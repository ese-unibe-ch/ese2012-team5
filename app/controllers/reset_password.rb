class ResetPassword < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get '/forgot_password' do
    message = session[:message]
    session[:message] = nil
    haml :forgot_password, :locals => { :info => message }
  end

  post '/forgot_password' do

    email = params[:email]

    if (!@database.email_exists?(email))
      session[:message] = "Email '#{email}' not registered"
      redirect '/forgot_password'
    end

    user = @database.user_by_email(email)
    # send email
    Helper::Mailer.send_pw_reset_mail(user)

    session[:message] = "Please check your mails for reset-link"
    redirect '/login'
  end

  get '/reset_password/:hash' do
    message = session[:message]
    session[:message] = nil

    #delete entries older than 24h from reset password hashmap
    @database.delete_old_entries_from_rp_hashmap(24)

    #check if hash exists
    if !(@database.hash_exists_in_rp_hashmap?(params[:hash]))
      session[:message] = "unknown/timed out link please request a new one"
      redirect '/login'
    end

    haml :user_reset_password, :locals => { :info => message,
                                           :hash => params[:hash]}
  end

  post '/reset_password/:hash' do

    password = params[:password]
    password_conf = params[:password_conf]
    hash = params[:hash]

    session[:message] = Helper::Validator.validate_password(password, password_conf, 4)
    if session[:message] != ""
      redirect "/reset_password/#{hash}"
    end

    #check for which user has that hash
    user = @database.get_user_from_rp_hashmap_by(hash)
    user.change_password(password)
    @database.delete_from_rp_hashmap(hash)

    session[:message] = "password changed, now log in"
    redirect '/login'
  end


end
