require 'net/http'
require 'uri'
require 'json'

#1. Obtener una lista
#2  Elegir tres
#3  Obtener las tres y guardar el header Set-Cookie
#4. Obtener /read con el header de cookies
#


def get_response(uri, req)
  Net::HTTP.start(uri.hostname, uri.port){|http|  http.request(req) }
end

def get(url, &builder)
  uri = URI(url)
  req = Net::HTTP::Get.new(uri.request_uri)
  builder[req]
  Net::HTTP.start(uri.hostname, uri.port){|http|  http.request(req) }
end

def parse_json(res)
  JSON.parse(res.body)
end

host = "http://httparty.herokuapp.com"

#1. Obtener las ids
list_res = get("#{host}/quotes") do |req|
  req['Accept'] = "application/json"
end
ids = parse_json(list_res).map{|quote| quote["id"] }

#2. Elegir tres al azar

sample = ids.sample(3)
puts "I've chosen: #{sample.inspect}"

cookie = ""

sample.each do |quote_id|

  quote_res = get("#{host}/quotes/#{quote_id}") do |req|
    req['Accept'] = "application/json"
    req['Cookie'] = cookie unless cookie.empty?
  end

  cookie = quote_res['Set-Cookie']
end

#Obtener las leídas
#
puts "Quotes I've read:"

b = get("#{host}/quotes/read") do |req|
  req['Accept'] = "text/plain"
  req['Cookie'] = cookie
end.body

puts b

