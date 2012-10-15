class DeleteAccount < Sinatra::Application

post '/delete_account' do
  if params[:confirm]!= "true"
    session[:message] = "You must confirm that you want to delete your account."
    redirect '/settings'
  end

  username = params[:username]
  password = params[:password]
  user = Marketplace::User.by_name(username)

  proper_password = BCrypt::Password.new(user.password)
  if proper_password == password
    user.delete_account
    session[:message] = "Account deleted. See you around"
    session[:name] = nil
    redirect '/'
  else
    session[:message] = "The password isn't correct"
    redirect '/settings'
  end
end

end