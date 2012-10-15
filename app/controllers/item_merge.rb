class ItemMerge < Sinatra::Application
  post "/item/:id/merge" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)
    current_user = Marketplace::User.by_name(session[:name])

    current_user.items.each { |item| current_item.quantity=item.quantity+current_item.quantity if item.name == current_item.name && item.id != current_item.id }
    current_user.items.pop

    redirect "/item/#{current_item.id}"
  end
end