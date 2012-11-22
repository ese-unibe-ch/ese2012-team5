class Settings < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/settings' do
    user = session[:name]

    redirect '/login' unless user != nil

    message = session[:message]
    session[:message] = nil
    haml :settings , :locals => { :user => @database.user_by_name(user),
                                  :info => message  }
  end


  post '/upload' do
    file = params[:file_upload]
    user = @database.user_by_name(session[:name])

    if file != nil
      filename = Helper::ImageUploader.upload_image(file, settings.root)
      user.picture = filename
    else
      session[:message] = "~error~please choose a file to upload"
    end

    redirect '/settings'
  end


  post '/details' do
    username = params[:user]
    new_details = params[:details]

    user = @database.user_by_name(username)

    user.details = new_details

    redirect '/settings'
  end


  post '/change_password' do
    username = params[:user]
    old_password = params[:old_password]
    new_password = params[:new_password]
    conf_password = params[:conf_password]

    user = @database.user_by_name(username)

    if Helper::Checker.check_password?(user, old_password)
      message = Helper::Validator.validate_password(new_password, conf_password, 4)
      if message != ""
        session[:message] = message
        redirect '/settings'
      end
      user.change_password(new_password)
    else
      session[:message] = "~error~old password was not correct!"
      redirect '/settings'
    end

    session[:message] = "~note~password changed!"
    redirect '/settings'
  end

end