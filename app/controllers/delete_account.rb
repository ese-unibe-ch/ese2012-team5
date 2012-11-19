class DeleteAccount < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post '/delete_account' do

    if params[:confirm] != "true"
      session[:message] = "error ~ You must confirm that you want to delete your account."
      redirect '/settings'
    end

    username = params[:username]
    password = params[:password]
    user = @database.user_by_name(username)

    if Helper::Checker.check_password?(user, password)
      @database.delete_user(user)
      session[:message] = "message ~ Account deleted. See you around!"
      session[:name] = nil
      redirect '/'
    else
      session[:message] = "error ~ The password isn't correct"
      redirect '/settings'
    end

  end

end