class DeleteAccount < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  post '/delete_account' do

    if params[:confirm] != "true"
      session[:message] = "You must confirm that you want to delete your account."
      redirect '/settings'
    end

    username = params[:username]
    password = params[:password]
    user = @database.user_by_name(username)

    proper_password = BCrypt::Password.new(user.password)

    if proper_password == password
      @database.delete_user(user)
      session[:message] = "Account deleted. See you around, snitch"
      session[:name] = nil
      redirect '/'
    else
      session[:message] = "The password isn't correct"
      redirect '/settings'
    end

  end

end