class Transaction < Sinatra::Application
  get "/edit/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)


    haml :edit_item, :locals => {:items => Marketplace::Item.all,
                                 :item => current_item}

  end


  post "/edit/:id" do
    current_item = Marketplace::Item.by_id(params[:id].to_i)


    current_item.name=params[:newName]

    current_item.price=params[:newPrice]


    haml :edit_item, :locals => {:items => Marketplace::Item.all,
                                 :item => current_item}


    redirect "/"
  end
end