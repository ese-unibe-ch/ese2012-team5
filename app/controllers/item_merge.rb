class ItemMerge < Sinatra::Application

  post "/item/:id/merge" do

    current_item = Marketplace::Item.by_id(params[:id].to_i)
    current_user = Marketplace::User.by_name(session[:name])

    master_item = current_user.items.detect{ |item| item.mergeable?(current_item) }
    master_item.merge(current_item)

    redirect "/"
  end

end