class ResetPassword < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Displays forgot_password view.
  get '/forgot_password' do
    message = session[:message]
    session[:message] = nil
    haml :forgot_password, :locals => { :info => message }
  end

  # Takes care of providing a user a hash to reset his email.
  post '/forgot_password' do
    email = params[:email]
    user = @database.user_by_email(email)

    if !@database.email_exists?(email)
      session[:message] = "~error~email '#{email}' doesn't exist in database!"
      redirect '/forgot_password'
    end

    Mailer.send_pw_reset_mail(user)

    session[:message] = "~note~email sent. ~note~please check your mails for reset-link."
    redirect '/login'
  end

  # Takes care of checking and processing a password reset hash, displays user_reset_password view if hash is valid.
  get '/reset_password/:hash' do
    message = session[:message]
    session[:message] = nil

    # Delete entries older than 24h from reset password hashmap
    @database.clean_pw_reset_older_as(24)

    if !@database.pw_reset_has?(params[:hash])
      session[:message] = "~error~unknown or timed out link, please request a new one!"
      redirect '/login'
    end

    haml :user_reset_password, :locals => { :info => message,
                                            :hash => params[:hash] }
  end

  # Takes care of resetting user password from hash.
  post '/reset_password/:hash' do
    password = params[:password]
    password_conf = params[:password_conf]
    hash = params[:hash]

    session[:message] = Validator.validate_password(password, password_conf)
    if session[:message] != ""
      redirect "/reset_password/#{hash}"
    end

    #check for which user has that hash
    user = @database.pw_reset_user_by_hash(hash)
    user.change_password(password)
    @database.delete_pw_reset(hash)

    session[:message] = "~note~password changed, now log in."
    redirect '/login'
  end

end
