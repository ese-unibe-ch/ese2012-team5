class ItemMerge < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  post "/item/:id/merge" do

    current_item = @database.item_by_id(params[:id].to_i)
    current_user = @database.user_by_name(session[:name])

    master_item = current_user.items.detect{ |item| item.mergeable?(current_item) }
    master_item.merge(current_item)

    redirect "/"
  end

end