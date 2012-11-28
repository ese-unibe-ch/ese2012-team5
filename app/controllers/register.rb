class Register < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/register' do
    message = session[:message]
    session[:message] = nil
    haml :register, :locals => { :info => message}
  end


  post '/register' do
    username = params[:username]
    password = params[:password]
    password_conf = params[:password_conf]
    email = params[:email]

    session[:message] = ""
    session[:message] += Helper::Validator.validate_username(username, 3, 12)
    session[:message] += Helper::Validator.validate_password(password, password_conf, 4)
    session[:message] += Helper::Validator.validate_email(email)
    if session[:message] != ""
      redirect '/register'
    end

    user = Marketplace::User.create(username, password, email)
    session[:message] = "~note~#{user.name} created.</br>before you are able to log in, you must first verify your account by following the link sent to your email."
    Helper::Mailer.send_verification_mail(user)

    redirect '/'
  end

end