class Authentication < Sinatra::Application

  @@id = 1

  get "/settings" do
    user = session[:name]
    redirect '/login' unless user != nil
    haml :settings , :locals => { :user => user }
  end

  post "/upload" do
    file = params[:file_upload]
    user = session[:name]

    return 413 if file[:tempfile].size > 400*1024

    filename = id_to_filename(@@id)
    user.picture = filename
    @@id = @@id + 1

    FileUtils::cp(file[:tempfile].path, File.join("public", "images", filename))

    redirect to("/upload/#{filename}")
  end

  def id_to_filename(id)
    "#{id}"
  end

  get "/upload/:filename" do
    send_file(File.join("public","images", params[:filename]))
  end

end