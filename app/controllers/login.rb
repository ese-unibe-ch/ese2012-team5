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
      session[:message] = "empty username or password - login failed!"
      redirect '/login'
    elsif user.nil?
      session[:message] = "user doesn't exist - login failed!"
      redirect '/login'
    end

    # Check password. Compares user input with hashed password via == method. Doesn't compare in plain text!
    proper_password = BCrypt::Password.new(user.password)
    if proper_password == password
      session[:name] = username
      redirect "/"
    else
      session[:message] = "wrong password - try again!!"
      redirect '/login'
    end
  end


  get '/logout' do
    session[:name] = nil
    session[:message] = "logged out"
    redirect '/login'
  end

end