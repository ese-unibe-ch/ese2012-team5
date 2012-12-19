class Verify < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Takes care of verifying an account from the hash-link the user gets by email.
  get '/verify_account/:hash' do
    hash = params[:hash]

    if @database.verification_has?(hash)
      user_to_verify = @database.verification_user_by_hash(hash)
      user_to_verify.verify

      @database.delete_verification(hash)
      session[:message] = "~note~congratulations, your account is now activated."
      redirect '/'
    else
      session[:message] = "~error~unknown link"
      redirect '/'
    end
  end

end