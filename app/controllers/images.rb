class Images < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # AK before the review, you should figure, if something must be in here.
  # If yes, put it here, if not, delete the file.

  #TODO seems as it would work without this get method, but why???
 # get '/images/:filename' do
 #   filename = params[:filename]
 #   Helper::ImageUploader.image(filename, settings.root)
 # end

end
