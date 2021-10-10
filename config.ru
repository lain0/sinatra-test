# frozen_string_literal: true

require './main'
require 'sidekiq/web'

require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

# if App.production?
#   Sidekiq::Web.use Rack::Auth::Basic do |username, password|
#     [username, password] == [Settings.sidekiq.username, Settings.sidekiq.password]
#    end
# end

run Sinatra::Application

#  run Rack::URLMap.new('/' => MyApp, '/sidekiq' => Sidekiq::Web)
