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

    session[:message] = Helper::Validator.validate_username(username, 3, 12)
    session[:message] += Helper::Validator.validate_password(password, password_conf, 4)
    session[:message] += Helper::Validator.validate_email(email)
    if session[:message] != ""
      redirect '/register'
    end

    # if there is a deactivated user with the new mail,
    # adopt this information and delete it from the deactivated_user_array
    user_deactivated = @database.get_deactivated_user_by_mail(email)
    if user_deactivated.nil?
      user = Marketplace::User.create(username, password, email)
      session[:message] = "#{user.name} created. Before you are able to log in, you must first verify your account by following the link sent to your email."
    else
      user = Marketplace::User.create(username, password, email)
      user.credits = user_deactivated.credits
      user.items = user_deactivated.items
      user.picture = user_deactivated.picture
      user.details = user_deactivated.details
      @database.delete_deactivated_user(user_deactivated)
      session[:message] = "#{user.name} reactivated. Before you are able to log in, you must first verify your account by following the link sent to your email."
    end

    @database.add_user(user)

    Helper::Mailer.send_verification_mail(user)

    redirect '/'
  end

end