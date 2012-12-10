class Login < Sinatra::Application

  before do
    @database=Marketplace::Database.instance
  end


  get '/login' do
    redirect '/' unless session[:name] == nil

    message = session[:message]
    session[:message] = nil
    haml :login, :locals => { :info => message}
  end


  post '/login' do

    username = params[:username]
    password = params[:password]
    user = @database.user_by_name(username)
    deactivated_user = @database.deactivated_user_by_name(username) # AK do you need to handle this differently?

    # If there is no user but a deactivated_user, swap.
    if user.nil? and !deactivated_user.nil? # AK `!deactivated_user.nil?` ==> `deactivated_user`
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
    if Helper::Checker.check_password?(user, password)
      if !(deactivated_user.nil?)
        session[:message] = "~note~user reactivated!</br>your old data was recovered."
      end
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
