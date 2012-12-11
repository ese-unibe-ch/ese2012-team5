class Login < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/login' do
    redirect '/' if session[:name]

    message = session[:message]
    session[:message] = nil
    haml :login, :locals => { :info => message}
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    user = @database.user_by_name(username)
    deactivated_user = @database.deactivated_user_by_name(username)

    # If there is no user but a deactivated_user, swap.
    if user.nil? and deactivated_user
      deactivated_user.activate
      user = deactivated_user
    end

    session[:message] = ""
    session[:message] += Helper::Validator.validate_string(username, "username")
    session[:message] += Helper::Validator.validate_string(password, "password")
    session[:message] += Helper::Validator.validate_user(user)
    if session[:message] != ""
      redirect '/login'
    end

    # Check password if correct login
    # If user was deactivated, activate him
    if Checker.check_password?(user, password)
      session[:message] = "~note~user reactivated!</br>your old data was recovered." if deactivated_user
      session[:name] = username
      redirect "/"
    else
      session[:message] = "~error~wrong password!!"
      redirect '/login'
    end
  end

  get '/logout' do
    session[:name] = nil
    session[:message] = "~note~logged out."

    redirect '/login'
  end

end