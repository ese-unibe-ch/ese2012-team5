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
      for item in  user.items
        if item.pictures.size > 0
          item.pictures.each{ |image_url| Helper::ImageUploader.remove_image(image_url, settings.root) }
        end
        if user.picture != nil
          Helper::ImageUploader.remove_image(user.picture, settings.root)
        end
      end

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