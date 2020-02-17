# typed: false
# frozen_string_literal: true

require_relative '../src/helper/general.rb'
leave_with(:configuration_error, 'Environment file not found!\n') unless File.exist?('config/environment.rb')

require_relative 'environment.rb'
require 'dotenv'
ENV_PATH = 'env'

configure :development do
  Dotenv.load("#{ENV_PATH}/development.env")
  enable :reloader
  set :logging, true
  set :sessions, true
  set :dump_errors, true
end

configure :production do
  Dotenv.load("#{ENV_PATH}/production.env")
  disable :reloader
  set :logging, false
  set :sessions, false
  set :dump_errors, false
end

set :bind, ENV['HOST']
set :port, ENV['PORT']
set :cache_ttl, ENV['CACHE_TTL']
set :cache_enabled, ENV['CACHE_ENABLED']
set :public_folder, File.dirname(__FILE__) + '/views'
set :rdoc, layout_engine: :erb
