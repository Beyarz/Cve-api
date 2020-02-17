# typed: true
# frozen_string_literal: true

require 'erb'
require 'json'
require_relative 'src/helper/general.rb'

begin
  require 'sinatra'
  require 'sanitize'
rescue LoadError
  import_failure
end

require_relative 'config/configuration.rb'
require_relative 'src/util/scan.rb'

before do
  cache_control :views, :must_revalidate, max_age: 60
end

get '/cve' do
  # Quick wash
  target = Sanitize.fragment(params['target'])
  year = Sanitize.fragment(params['year'])
  @names = [get_cve(target, year)]

  # Check if result should be returned as text/html instead of application/json
  if Sanitize.fragment(params['display']) == true
    content_type :html
    erb :result
  else
    content_type :json
    @names.to_json
  end
end

# Deliver status
get '/status' do
  '200'
end

# Default page
get '/' do
  bind = ENV['HOST']
  port = ENV['PORT']
  erb :index, locals: { bind: bind, port: port }, format: :html5
end

get '/stylesheet/:file' do |filename|
  filename = 'index.css' unless filename.match(/^[A-z0-9]+$/).nil?
  send_file "views/stylesheet/#{filename}", type: :css, disposition: :inline
end

# Disallowed methods
FORBIDDEN = 403
FORBIDDEN_DESCRIPTION = 'Disallowed request method.'

post '/' do
  halt FORBIDDEN, FORBIDDEN_DESCRIPTION
end
put '/' do
  halt FORBIDDEN, FORBIDDEN_DESCRIPTION
end
patch '/' do
  halt FORBIDDEN, FORBIDDEN_DESCRIPTION
end
delete '/' do
  halt FORBIDDEN, FORBIDDEN_DESCRIPTION
end
options '/' do
  halt FORBIDDEN, FORBIDDEN_DESCRIPTION
end
link '/' do
  halt FORBIDDEN, FORBIDDEN_DESCRIPTION
end
unlink '/' do
  halt FORBIDDEN, FORBIDDEN_DESCRIPTION
end
