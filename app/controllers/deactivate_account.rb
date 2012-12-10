class DeactivateAccount < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])

    redirect '/login' unless @current_user
  end


  post '/deactivate_account' do
    password = params[:password]

    if Helper::Checker.check_password?(@current_user, password)
      @current_user.deactivate
      session[:message] = "~note~account deactivated."
      session[:name] = nil
      redirect '/'
    else
      session[:message] = "~error~the password isn't correct!"
      redirect '/settings'
    end
  end

end