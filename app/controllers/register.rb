class Register < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Displays register view to not logged in users.
  get '/register' do
    if session[:name].nil?
      message = session[:message]
      session[:message] = nil
      haml :register, :locals => { :info => message}
    else
      redirect '/'
    end

  end

  # Takes care of registration process.
  post '/register' do
    username = params[:username]
    password = params[:password]
    password_conf = params[:password_conf]
    email = params[:email]

    session[:message] = ""
    session[:message] += Validator.validate_username(username)
    session[:message] += Validator.validate_password(password, password_conf)
    session[:message] += Validator.validate_email(email)
    if session[:message] != ""
      redirect '/register'
    end

    user = Marketplace::User.create(username, password, email)
    session[:message] = "~note~#{user.name} created.~note~Before you are able to log in, you must first verify your account by following the link sent to your email."
    Mailer.send_verification_mail(user)

    redirect '/'
  end

end