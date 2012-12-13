class Paradise < Sinatra::Application

  # If no controller feels itself responsible for a get query this will lead it into the paradise
  get %r{(/.*?)+} do
    redirect '/login'
  end

end