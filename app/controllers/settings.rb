class Settings < Sinatra::Application

  @@id = 1

  get '/settings' do
    user = session[:name]
    message = session[:message]
    session[:message] = nil
    redirect '/login' unless user != nil
    haml :settings , :locals => { :user => Marketplace::User.by_name(user),
                                  :info => message  }
  end

  # saves picture with name '@@id' in public/images
  post '/upload' do
    file = params[:file_upload]
    user = Marketplace::User.by_name(session[:name])

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

end