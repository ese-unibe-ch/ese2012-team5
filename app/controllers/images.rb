class Images < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  #TODO seems as it would work without this get method, but why???
 # get '/images/:filename' do
 #   filename = params[:filename]
 #   Helper::ImageUploader.image(filename, settings.root)
 # end

end