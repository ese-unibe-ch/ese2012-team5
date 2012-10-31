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

    FileUtils::cp(file[:tempfile].path, "app/public/images/#{filename}")

    session[:message] = "message ~ your picture is stored"
    redirect '/settings'
  end

  get '/upload/:filename' do
    send_file(File.join("app/public/images/#{filename}"))
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
      session[:message] = "error ~ old password was not correct!"
      redirect '/settings'
    end

    session[:message] = "message ~ password changed!"
    redirect '/settings'
  end

end