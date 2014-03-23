require 'rubygems'
require 'bundler'

Bundler.require

class PizzaChoice < Sinatra::Base
  set :haml, format: :html5

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    register Sinatra::PubSub
  end

  Sinatra::PubSub.set(
    cors: false
  )

  # EventMachine.next_tick do
  #   EventMachine::PeriodicTimer.new(1) do
  #     Sinatra::PubSub.publish('tick', type: 'tick')
  #   end
  # end

  get "/" do
    haml :index
  end

  get "/js/app.js" do
    coffee :app
  end
end
