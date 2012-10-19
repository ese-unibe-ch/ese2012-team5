class Buy < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  get '/buy' do

    redirect '/login' unless session[:name]

    quantity = params[:quantity].to_i
    category = params[:category]
    items = @database.category_with_name(category)

    if items == nil
      session[:message] = "Item name not found - could not create category"
      redirect '/'
    end

    message = session[:message]
    session[:message] = nil
    haml :buy, :locals => { :info => message,
                            :quantity => quantity,
                            :items => items }
  end

end