class Login < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Displays login view to not logged in users.
  get '/login' do
    redirect '/' if session[:name]

    message = session[:message]
    session[:message] = nil
    haml :login, :locals => { :info => message}
  end

  # Takes care of logging in process. Redirects to login view as long as login is not successful.
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
    session[:message] += Validator.validate_string(username, "username")
    session[:message] += Validator.validate_string(password, "password")
    session[:message] += Validator.validate_user(user)
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

  # Takes care of logging out
  get '/logout' do
    if !session[:name].nil?
      session[:name]= nil
      session[:message] = "~note~logged out."
    end

    redirect '/login'
  end

end