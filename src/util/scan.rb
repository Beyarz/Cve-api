# typed: strict
# frozen_string_literal: true

require 'net/https'
require 'base64'
require_relative '../helper/general.rb'
require_relative '../../config/configuration.rb'
require_relative 'cache.rb'

begin
  require 'nokogiri'
rescue LoadError
  import_failure
end

def args_filter(keyword)
  return if keyword.empty? do
    puts 'Missing target parameter.'
    puts 'Target parameter required!'
    leave(:usage_error)
  end
end

def http_get(formatted_link)
  # Merge argument with link as param
  link = URI(formatted_link)
  resp = ''

  # Start ssl session with host
  Net::HTTP.start(link.host, 443, use_ssl: true) do |https|
    request = Net::HTTP::Get.new(link)
    response = https.request(request)
    response.message == 'OK' ? resp += response.body : false
  end

  return resp
end

def retrieve_cve(keyword, src = 'https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=', css_filter = '#TableWithRules td')
  resp = http_get(src + keyword)
  raw = Nokogiri::HTML(resp)

  return raw.css(css_filter)
end

def generate_structure(year_arg, cve, year, desc)
  # Display the available CVEs
  structure = {}

  if year_arg.to_s.empty?
    (cve.count - 1).times do |x|
      structure[x] = { 'cve': cve[x], 'year': year[x], 'desc': desc[x] }
    end
  else
    (cve.count - 1).times do |x|
      structure[x] = { 'cve': cve[x], 'year': year[x], 'desc': desc[x] } if year_arg == year[x]
    end
  end

  return structure
end

def get_cve(*args)
  # Display guide if no or too many keywords provided
  args_filter(keyword) if args.length > 2 || args.length.zero?

  keyword = args[0]
  year_arg = args[1]
  year_arg = Time.now.year.to_s if args[1] == 'latest'

  if ENV['CACHE_ENABLED'] == 'true'
    # Create cache key
    cache_key = "cve_#{Base64.encode64(keyword)}_#{Base64.encode64(year_arg == '' ? 'all' : year_arg)}".gsub(' ', '')

    # Check if cache exists
    cached_value = Cache.get_by(cache_key)
    return cached_value unless cached_value.nil?
  end

  parsed = retrieve_cve(keyword)

  cve = []
  year = []
  desc = []

  (0..parsed.count - 1).each do |index|
    if index.even?
      cve << parsed[index].text
      year << parsed[index].text.split('-')[1]
    else
      desc << parsed[index].text.strip
    end
  end

  structure = generate_structure(year_arg, cve, year, desc)

  if ENV['CACHE_ENABLED'] == 'true'
    # Update cache
    Cache.add(cache_key, structure, ENV['CACHE_TTL'])
  end

  return structure
end
