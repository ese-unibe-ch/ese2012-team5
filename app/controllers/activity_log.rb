class ActivityLog < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get "/activity_log" do
    current_user = @database.user_by_name(session[:name])

    all_subscriptions = current_user.subscriptions
    all_activities = Array.new
    all_subscriptions.each{ |subscription|
      subscription.activities.each{ |activity|
        all_activities << activity
      }
    }

    all_activities
    all_activities.sort! {|a,b| b.time <=> a.time }

    message = session[:message]
    session[:message] = nil
    haml :activity_log, :locals => {  :info => message,
                                      :subscriptions => all_subscriptions,
                                      :activities => all_activities }
  end

end