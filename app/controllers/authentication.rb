require 'tilt/haml'
require 'bcrypt'
require '../models/marketplace/user'

class Authentication < Sinatra::Application

  get "/login" do
    haml :login
  end

  post "/login" do
    username = params[:username]
    password = params[:password]
    user = Marketplace::User.by_name(username)


    if username == "" or password == "" or user.nil?
      redirect "/login"
    end

    # we need to implement the bcrypt here... somehow
    # while registration the password will be stored as a hash in user.password
    if password == BCrypt::Password.new(user.password)  # note at oli: i don't know if this is correct method
      session[:name] = name
      redirect "/"
    else
      redirect "/login"
      # later may pass message that password was wrong
    end
  end

  get "/logout" do
    redirect "/login"
  end

  get "/register" do
    haml :register
  end

  # method incomplete
  post "/register" do
    username = params[:username]
    password = params[:password]
    existing_user = Marketplace::User.by_name(username)

    if username_taken?(username)
      redirect "/register"
      # later may pass message that user already exists
    end

    new_user = Marketplace::User.create(username)
    new_user.save()
    # add password to user
    new_user.password = BCrypt::Password.create(password) # note at oli: i don't know if this is correct method

    # later may pass message that registration succeded
    redirect "/login"
  end

  def username_taken?(username)
    nil != Marketplace::User.by_name(username)
  end


end
