class User < Sinatra::Application

  get "/user/:name" do

    username = params[:name]
    message = session[:message]
    session[:message] = nil
    user = Marketplace::User.by_name(username)
    details = user.details.gsub(/\n/, '<br />')

    #the gsub() method changes textarea-style linebreaks to html-style linebreaks

    if username == session[:name]
      haml :user_profile_own, :locals => {  :user => user,
                                            :info => message,
                                            :details => details}
    else
      haml :user_profile, :locals => {  :user => user,
                                        :current_user => Marketplace::User.by_name(session[:name]),
                                        :info => message,
                                        :details => details}
    end

  end

end