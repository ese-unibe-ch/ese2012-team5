class Item < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Displays the profile of the item with given id
  get "/item/:id" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])


    message = session[:message]
    session[:message] = nil

    if current_user == current_item.owner
      haml :item_profile_own, :locals => {  :item => current_item,
                                            :info => message        }
    else
      haml :item_profile, :locals => {  :item => current_item,
                                        :info => message,
                                        :canBuy => user_able_to_buy?(current_user, current_item)   }
    end

  end

  # Decide if user is able to buy the item
  def user_able_to_buy?(current_user, current_item)
    if current_user
      current_user.credits >= current_item.price
    else
      false
    end
  end

end