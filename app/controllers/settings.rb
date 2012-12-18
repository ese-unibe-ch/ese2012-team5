class Settings < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
    @current_user = @database.user_by_name(session[:name])
  end

  # Displays setting page to logged in users.
  get '/settings' do
    redirect '/login' unless @current_user

    message = session[:message]
    session[:message] = nil
    haml :settings , :locals => { :user => @current_user,
                                  :info => message  }
  end

  # Takes care of uploading a user profile picture.
  post '/upload_profile_picture' do
    file = params[:file_upload]

    if file != nil
      filename = ImageUploader.upload_image(file, settings.root)
      @current_user.picture = filename
    else
      session[:message] = "~error~please choose a file to upload"
    end

    redirect '/settings'
  end

  # Takes care of changing user details.
  post '/details' do
    new_details = params[:details]

    @current_user.details = new_details

    redirect '/settings'
  end

  # Takes care of changing user password.
  post '/change_password' do
    old_password = params[:old_password]
    new_password = params[:new_password]
    conf_password = params[:conf_password]


    if Checker.check_password?(@current_user, old_password)
      session[:message] = Validator.validate_password(new_password, conf_password)
      redirect '/settings' unless session[:message] == ""
      @current_user.change_password(new_password)
    else
      session[:message] = "~error~old password was not correct!"
      redirect '/settings'
    end

    session[:message] = "~note~password changed!"
    redirect '/settings'
  end

end