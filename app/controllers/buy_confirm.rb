class BuyConfirm < Sinatra::Application

  before do
    @database = Marketplace::Database.instance
  end

  post '/buy/confirm' do

    params.each do |key, param|
      params[key] = param
    end

    x = 0
    map = Hash.new
    while params.key?("id#{x}")
      map[params["id#{x}"]] = params["quantity#{x}"]
      x = x + 1
    end


    message = session[:message]
    session[:message] = nil
    haml :buy_confirm, :locals => { :info => message,
                                    :map => map }
  end

end