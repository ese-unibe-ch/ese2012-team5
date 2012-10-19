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

end