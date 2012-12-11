class Images < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  #get '/images/:filename' do
  #  filename = params[:filename]
  #  Helper::ImageUploader.image(filename, settings.root)
  #end

end