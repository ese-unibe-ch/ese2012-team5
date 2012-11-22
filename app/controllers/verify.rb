class Verify < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/verify_account/:hash' do

    message = session[:message]
    session[:message] = nil
    hash = params[:hash]

    #check if hash exists
    if !(@database.hash_exists_in_ver_hashmap?(hash))
      session[:message] = "~error~unknown link"
      redirect '/'
    else
      #activate user
      @database.get_user_from_ver_hashmap_by(hash).verify

      #delete user from verification hashmap
      @database.delete_entry_from_ver_hashmap(hash)
      session[:message] = "~note~congratulations, your account is now activated."
      redirect '/'
    end
  end

end