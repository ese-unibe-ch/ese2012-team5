# handles login and register
class Authentication < Sinatra::Application

  get "/login" do
    message = session[:message]
    session[:message] = nil
    haml :login, :locals => { :info => message}
  end

  post "/login" do
    username = params[:username]
    password = params[:password]
    user = Marketplace::User.by_name(username)

    # check for any empty input or non-existent user
    if username == "" or password == ""
      session[:message] = "empty username or password - login failed!"
      redirect "/login"
      elsif user.nil?
      session[:message] = "user doesn't exist - login failed!"
      redirect "/login"
    end

    # Check password. Compares user input with hashed password via == method. Doesn't compare in plain text!
    proper_password = BCrypt::Password.new(user.password)
    if proper_password == password
      session[:name] = username
      redirect "/"
    else
      session[:message] = "wrong password - try again!!"
      redirect "/login"
    end
  end


  get "/logout" do
    session[:name] = nil
    session[:message] = "logged out"
    redirect "/login"
  end


  get "/register" do
    message = session[:message]
    session[:message] = nil
    haml :register, :locals => { :info => message}
  end

  post "/register" do
    username = params[:username]
    password = params[:password]
    password_conf = params[:password_conf]

    if username_taken?(username)
      session[:message] = "username already in use"
      redirect "/register"
    end

    if !password==password_conf
      session[:message] = "password and confirmation don't match"
      redirect "/register"
    end

    new_user = Marketplace::User.create(username)


    #caution: attr password [String] needs to be added to Marketplace::User.
    new_user.password = BCrypt::Password.create(password)
    new_user.save()

    session[:message] = "#{new_user.name} created, now log in"
    redirect "/login"
  end


  def username_taken?(username)
    nil != Marketplace::User.by_name(username)
  end

end
