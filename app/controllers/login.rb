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

    # check for any empty input or non-existent user
    if username == "" or password == ""
      session[:message] = "error ~ empty username or password - login failed!"
      redirect '/login'
    elsif user.nil?
      session[:message] = "error ~ user doesn't exist - login failed!"
      redirect '/login'
    elsif user.verified==false
      session[:message] = "error ~ Your account isn't verified. You must first click on the link in the email received right after registration before you can log in."
      redirect '/login'
    end

    # Check password. Compares user input with hashed password via == method. Doesn't compare in plain text!
    if Helper::Checker.check_password?(user, password)
      session[:name] = username
      redirect "/"
    else
      session[:message] = "error ~ wrong password - try again!!"
      redirect '/login'
    end
  end


  get '/logout' do
    session[:name] = nil
    session[:message] = "message ~ logged out"
    redirect '/login'
  end

end