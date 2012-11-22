class DeactivateAccount < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  post '/deactivate_account' do

    username = params[:username]
    password = params[:password]
    user = @database.user_by_name(username)

    if Helper::Checker.check_password?(user, password)

      @database.deactivate_user(user)
      session[:message] = "message ~ Account deactivated. See you around!"
      session[:name] = nil
      redirect '/'
    else
      session[:message] = "error ~ The password isn't correct"
      redirect '/settings'
    end

  end

end