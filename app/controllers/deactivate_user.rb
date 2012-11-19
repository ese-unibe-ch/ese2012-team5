class DeactivateUser < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  post '/deactivate_user' do

    if params[:confirm] != "true"
      session[:message] = "error ~ You must confirm that you want to deactivate your account."
      redirect '/settings'
    end

    username = params[:username]
    password = params[:password]
    user = @database.user_by_name(username)

    if Helper::Checker.check_password?(user, password)
      for item in  user.items
        if item.pictures.size > 0
          item.pictures.each_with_index{|pic,index|
            FileUtils.remove(File.join("public","item_images", "#{item.pictures[index]}"))
          }
        end
      end

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