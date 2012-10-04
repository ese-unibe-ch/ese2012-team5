require 'rubygems'
require 'sinatra'
require 'tilt/haml'

require '../app/models/marketplace/user'
require '../app/models/marketplace/item'

require '../app/controllers/main'
require '../app/controllers/authentication'
require '../app/controllers/transaction'
require '../app/controllers/user'
require '../app/controllers/item'

class App < Sinatra::Base

  use Authentication
  use Main
  use Transaction
  use User
  use Item

  enable :sessions
  set :public_folder, 'app/public'

  configure :development do
    # add dummy users here
  end

end

# Now, run it
App.run!