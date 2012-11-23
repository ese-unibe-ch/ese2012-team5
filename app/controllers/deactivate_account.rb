class DeactivateAccount < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post '/deactivate_account' do

    if params[:confirm] != "true"
      session[:message] = "~error~you must confirm that you want to deactivate your account!"
      redirect '/settings'
    end

    username = params[:username]
    password = params[:password]
    user = @database.user_by_name(username)

    if Helper::Checker.check_password?(user, password)
      user.deactivate
      session[:message] = "~note~account deactivated.</br>see you around!"
      session[:name] = nil
      redirect '/'
    else
      session[:message] = "~error~the password isn't correct!"
      redirect '/settings'
    end

  end

end