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
      for item in  user.items
        if item.pictures.size > 0
          item.pictures.each_with_index{|pic,index|
            FileUtils.remove(File.join("public","item_images", "#{item.pictures[index]}"))
          }
        end
      end

      @database.delete_user(user)
      session[:message] = "Account deleted. See you around!"
      session[:name] = nil
      redirect '/'
    else
      session[:message] = "The password isn't correct"
      redirect '/settings'
    end

  end

end