class Verify < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/verify_account/:hash' do

    message = session[:message] # AK You should abstract from this by introducing a `pop_message` helper.
    session[:message] = nil     # In Ruby, you can either introduce this in a separate module
    hash = params[:hash]        # or add the method to the class of the session directly.

    #check if hash exists
    if !(@database.verification_has?(hash))
      session[:message] = "~error~unknown link"
      redirect '/'
    else
      #activate user
      @database.verification_user_by_hash(hash).verify

      #delete user from verification hashmap
      @database.delete_verification(hash)
      session[:message] = "~note~congratulations, your account is now activated."
      redirect '/'
    end
  end

end
