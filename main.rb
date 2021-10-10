# frozen_string_literal: true

require 'sinatra'
require 'sidekiq'
require 'sidekiq/web'
# require 'sequel'

get '/frank-says' do
  'Put this in your pipe & smoke it!'
end

get '/' do
  'Hello World'
end

get '/sidekiq' do
    run Sidekiq::Web
end
