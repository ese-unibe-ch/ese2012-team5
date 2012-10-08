class Authentication < Sinatra::Application

  get "/settings" do
    user = session[:name]
    haml :settings , :locals => { :user => user }
  end

  post "/text/:id/images" do
    text = Text.by_id(params[:id].to_i)
    return 404 unless text
    return 401 unless text.editable? user
    file = params[:file_upload]
    return 413 if file[:tempfile].size > 400*1024

    filename = id_image_to_filename(text.id, file[:filename])

    FileUtils::cp(file[:tempfile].path, File.join("public", "images", filename))

    redirect to("/text/#{params[:id]}/")
  end

  def id_image_to_filename(id, path)
    "#{id}_#{path}"
  end

  get "/text/:id/images/:pic" do
    send_file(File.join("public","images", id_image_to_filename(params[:id], params[:pic])))
  end

end