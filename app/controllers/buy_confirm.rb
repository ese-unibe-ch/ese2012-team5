class BuyConfirm < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  # Displays the buy_confirm view, where users are prompted to confirm the items, item prize and item quantities they are about to buy
  post '/buy/confirm' do
    map = Checker.create_buy_map(params)

    haml :buy_confirm, :locals => { :map => map }
  end

end