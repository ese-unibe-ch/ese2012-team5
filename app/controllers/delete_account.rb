class DeleteAccount < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
  end


  post '/delete_account' do
    password = params[:password]

    if params[:confirm] != "true"
      session[:message] = "~error~you must confirm that you want to delete your account!"
      redirect '/settings'
    end

    if Checker.check_password?(@current_user, password)
      @current_user.delete
      session[:message] = "~note~account deleted."
      session[:name] = nil
      redirect '/'
    else
      session[:message] = "~error~the password isn't correct!"
      redirect '/settings'
    end
  end

end