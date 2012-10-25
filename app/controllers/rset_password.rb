
class RsetPassword < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get '/rset_password/:hash' do
    message = session[:message]
    session[:message] = nil
    #check if hash exists


    haml :rset_password, :locals => { :info => message,
                                      :hash => hash

                                    }
  end

  post '/rset_password' do


    password = params[:password]
    password_conf = params[:password_conf]
    hash = params[:hash]

    validate_password(password, password_conf, 4)

    #check for which user has that hash

    @database.user_by_name(user)
    user.change_password(password)


    session[:message] = "password changed, now log in"
    redirect '/login'
  end

  get '/forgot_password' do
    message = session[:message]
    session[:message] = nil
    haml :forgot_password, :locals => { :info => message}
  end

  post '/forgot_password' do

    email = params[:email]

    if (!email_exists?(email))
      session[:message] = "email not registered"
      redirect '/forgot_password'
    end

    #hash generieren/in map speichern
    hash = "12tu3y1gki4p23ui"
    #mail senden
    Helper::Mailer.send_pw_reset_mail_to(email, "Hi, \nfollow this link to reset your password.
        http://localhost:4567/rset_password/#{hash}")

    session[:message] = "check your mails for reset-link "
    redirect '/login'
  end



  def validate_reset_password(password, password_conf, length)
    if password != password_conf
      session[:message] = "password and confirmation don't match"
      redirect '/rset_password'
    end
    if password.length<length
      session[:message] = "password too short"
      redirect '/rset_password'
    end
    if !(password =~ /[0-9]/)
      session[:message] = "no number in password"
      redirect '/rset_password'
    end
    if !(password =~ /[A-Z]/)
      session[:message] = "no uppercase letter in password"
      redirect '/rset_password'
    end
    if !(password =~ /[a-z]/)
      session[:message] = "no lowercase letter in password"
      redirect '/rset_password'
    end
  end

  def email_exists?(mail)
   emails = @database.all_emails()
   emails.include?(mail)
  end
end
