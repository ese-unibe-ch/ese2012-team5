<<<<<<< HEAD
class Authentication < Sinatra::Application
  # To change this template use File | Settings | File Templates.
end
=======
require 'tilt/haml'
require 'app/modelsuser'

class Authentication < Sinatra::Application

  get "/login" do
    message = session[:message]
    session[:message] = nil
    haml :login , :locals => { :message => message }
  end

  post "/login" do
    name = params[:user_name]
    password = params[:password]
    user = Marketplace::User.with_name name

    if name == "" or password == "" or user.nil? or password != name
      session[:message] = "Login failed"
      redirect "/login"
    else
      session[:name] = name
      redirect '/'
    end
  end

  get "/logout" do
    session[:name] = nil
    redirect "/login"
  end


end
>>>>>>> test commit
