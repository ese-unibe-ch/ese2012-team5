class ActivityLog < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  get "/activity_log/:items_per_page" do
    current_user = @database.user_by_name(session[:name])
    items_per_page = params[:items_per_page].to_i

    redirect '/login' if current_user == nil


    all_subscriptions = current_user.subscriptions
    all_activities = Array.new
    all_subscriptions.each{ |subscription|
      subscription.activities.each{ |activity|
        all_activities << activity
      }
    }

    all_activities.sort! {|a,b| b.time <=> a.time }

    if all_activities.size > items_per_page
      all_activities = all_activities[0..(items_per_page-1)]
    else
      items_per_page = all_activities.size
    end

    message = session[:message]
    session[:message] = nil
    haml :activity_log, :layout => (request.xhr? ? false : :layout),
                                    :locals => {:info => message,
                                                :subscriptions => all_subscriptions,
                                                :activities => all_activities,
                                                :items_per_page => items_per_page }
  end

end