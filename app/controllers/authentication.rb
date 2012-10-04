require 'tilt/haml'
require 'app/models/marketplace/user'

class Authentication < Sinatra::Application

  get "/login" do
    haml :login
  end

  post "/login" do
    username = params[:username]
    password = params[:password]
    user = Marketplace::User.by_name(username)

    # we need to implement the bcrypt here... somehow
    # while registration the password will be stored as a hash in user.password
    if username == "" or password == "" or user.nil? or password != username
      redirect "/login"
    else
      session[:name] = name
      redirect "/"
    end
  end

  get "/logout" do
    redirect "/login"
  end

  get "/register" do
    haml :register
  end

  post "/register" do
    username = params[:username]
    password = params[:password]
    existing_user = Marketplace::User.by_name(username)

    if(existing_user != nil)
      redirect "/register"
      # later may pass message that user already exists
    end

    new_user = Marketplace::User.create(username)
    # add password to user

    # later may pass message that registration succeded
    redirect "/login"
  end


end
