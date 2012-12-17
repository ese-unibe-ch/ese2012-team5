class BuyConfirm < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post '/buy/confirm' do
    map = Checker.create_buy_map(params)

    haml :buy_confirm, :locals => { :map => map }
  end

end