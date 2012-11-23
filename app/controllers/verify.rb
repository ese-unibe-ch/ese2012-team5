class Verify < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get '/verify_account/:hash' do

    message = session[:message]
    session[:message] = nil
    hash = params[:hash]

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