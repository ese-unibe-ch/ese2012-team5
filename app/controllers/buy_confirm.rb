class BuyConfirm < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end


  post '/buy/confirm' do

    # Create a hash-table
    # key is the 'item.id'
    # value is the 'quantity' to buy
    x = 0
    map = Hash.new
    while params.key?("id#{x}")
      map[params["id#{x}"]] = params["quantity#{x}"]
      x = x + 1
    end

    haml :buy_confirm, :locals => { :map => map }
  end

end