class Item < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Displays item view, which is different for each of these three cases:
  # -Logged in user displays his own item
  # -Logged in user displays another user's item
  # -Guest (not logged in user) displays an item
  get '/item/:id' do
    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])

    message = session[:message]
    session[:message] = nil

    if current_user
      if current_user == current_item.owner
        haml :item_profile_own, :locals => {  :item => current_item,
                                              :info => message,
                                              :comments => current_item.comments }
      else
        haml :item_profile, :locals => {  :item => current_item,
                                          :info => message,
                                          :canBuy => current_user.can_buy_item?(current_item,1), # At least one
                                          :is_following => current_user.follows?(current_item),
                                          :is_guest => false,
                                          :comments => current_item.comments }
      end
    else
      haml :item_profile, :locals => {  :item => current_item,
                                        :info => message,
                                        :canBuy => false,
                                        :is_following => nil,
                                        :is_guest => true,
                                        :comments => nil }
    end
  end

end