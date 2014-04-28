require 'bundler'
Bundler.require

require "sinatra/config_file"
require "json"

if ENV["REDISTOGO_URL"] != nil
  uri = URI.parse(ENV["REDISTOGO_URL"])
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  redis = Redis.new(host: "127.0.0.1", port: "6379")
end

Redis.current = redis

class Pizza
  include Redis::Objects

  attr_reader :id
  counter :vote, start: 0, expiration: 21600


  def initialize(id)
    @id = id.to_i
  end

  def vote!
    vote.increment
  end
end

class PizzaChoice < Sinatra::Base
  set :haml, format: :html5

  configure :development do
    register Sinatra::Reloader
  end

  register Sinatra::PubSub
  register Sinatra::ConfigFile

  config_file 'config/pizza.yml'

  Sinatra::PubSub.set(
    cors: false
  )

  helpers do
    def pizza_list
      settings.pizza
    end
  end

  #EventMachine.next_tick do
  #  EventMachine::PeriodicTimer.new(1) do
  #    Sinatra::PubSub.publish('tick', type: 'tick')
  #  end
  #end

  get "/" do
    haml :index
  end

  get "/pizzas" do
    pizza_list.map do |pizza|
      _p = Pizza.new(pizza["id"])
      pizza["count"] = _p.vote.value.to_i

      pizza
    end.to_json
  end

  get "/js/app.js" do
    coffee :app
  end

  post "/pizzas/:id/vote" do
    count = Pizza.new(params[:id]).vote!

    Sinatra::PubSub.publish('vote', id: params[:id], count: count)
    {status: 'ok'}.to_json
  end
end
