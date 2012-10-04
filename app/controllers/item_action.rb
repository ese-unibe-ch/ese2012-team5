class ItemAction < Sinatra::Application

  get '/activate' do
    redirect "/"
  end

  get '/inactivate' do
    redirect "/"
  end

  get '/create' do
    redirect "/"
  end

  post '/activate' do
    item_id = params[:item_id]
    item = Marketplace::Item.by_id(item_id)
    item.activate

    session[:message] = "You activated #{item.name} for sale"

    redirect "/"
  end

  post '/inactivate' do
    item_id = params[:item_id]
    item = Marketplace::Item.by_id(item_id)
    item.inactivate

    session[:message] = "You inactivated #{item.name} from sale"

    redirect "/"
  end

  post '/create' do
    owner_name = params[:owner]
    item_name = params[:item_name]
    price = params[:price]

    owner = Marketplace::User.by_name(owner_name)
    owner.add_item(Marketplace::Item.make(item_name, price, owner))

    session[:message] = "You created #{item_name}"

    redirect "/"
  end

end