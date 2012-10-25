class Settings < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  @@id = 1

  get '/settings' do
    user = session[:name]

    redirect '/login' unless user != nil

    message = session[:message]
    session[:message] = nil
    haml :settings , :locals => { :user => @database.user_by_name(user),
                                  :info => message  }
  end

  # saves picture with name '@@id' in public/images
  post '/upload' do
    file = params[:file_upload]
    user = @database.user_by_name(session[:name])

    return 413 if file[:tempfile].size > 400*1024

    filename = "#{@@id}"
    user.picture = filename
    @@id = @@id + 1

    FileUtils::cp(file[:tempfile].path, File.join("public", "images", filename))

    session[:message] = " your picture is stored at '/upload/#{filename}'"
    redirect '/settings'
  end

  get '/upload/:filename' do
    send_file(File.join("public","images", params[:filename]))
  end

  post '/details' do
    user_name = params[:user]
    new_details = params[:details]

    user = @database.user_by_name(user_name)

    user.details = new_details

    redirect '/settings'
  end

  post '/change_password' do
    user_name = params[:user]
    old_password = params[:old_password]
    new_password = params[:new_password]
    conf_password = params[:conf_password]

    user = @database.user_by_name(user_name)

    proper_password = BCrypt::Password.new(user.password)

    if proper_password == old_password
      validate_password(new_password, conf_password, 4)
      user.change_password(new_password)
    else
      session[:message] = "old password was not correct!"
      redirect '/settings'
    end
    session[:message] = "password changed!"
    redirect '/settings'
  end

  #validates password input by user.
  # @param [String] password user chooses
  # @param [String] password_conf password confirmation
  # @param [Integer] length minimal length in characters password must have
  def validate_password(password, password_conf, length)
    if password != password_conf
      session[:message] = "password and confirmation don't match"
      redirect '/settings'
    end
    if password.length<length
      session[:message] = "password too short"
      redirect '/settings'
    end
    if !(password =~ /[0-9]/)
      session[:message] = "no number in password"
      redirect '/settings'
    end
    if !(password =~ /[A-Z]/)
      session[:message] = "no uppercase letter in password"
      redirect '/settings'
    end
    if !(password =~ /[a-z]/)
      session[:message] = "no lowercase letter in password"
      redirect '/settings'
    end
  end

end