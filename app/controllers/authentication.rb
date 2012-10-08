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

    # check for any empty input or username don't exist
    if username == "" or password == ""
      session[:message] = "empty username or password"
      redirect "/login"
      elsif user.nil?
      session[:message] = "username don't exists"
      redirect "/login"
    end

    # check password
    real_password = BCrypt::Password.new(user.password)
    if password == real_password
      session[:name] = name
      redirect "/"
    else
      session[:message] = "login failed"
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
    existing_user = Marketplace::User.by_name(username)

    if username_taken?(username)
      session[:message] = "username already in use"
      redirect "/register"
    end

    new_user = Marketplace::User.create(username)
    new_user.password = BCrypt::Password.create(password)
    new_user.save()

    session[:message] = "#{new_user.name} created, please log in"
    redirect "/login"
  end


  def username_taken?(username)
    nil != Marketplace::User.by_name(username)
  end

end
