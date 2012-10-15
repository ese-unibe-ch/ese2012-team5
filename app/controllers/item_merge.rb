class ItemMerge < Sinatra::Application
  post "/item/:id/merge" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)
    current_user = Marketplace::User.by_name(session[:name])

    current_user.items.each { |item| item.quantity=item.quantity+current_item.quantity if item.name == current_item.name && item.id != current_item.id }
    current_user.items.delete(current_item)

    redirect "/"
  end
end