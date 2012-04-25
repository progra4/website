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

def parse_json(res)
  JSON.parse(res.body)
end

host = "http://httparty.herokuapp.com"

#1. Obtener las ids
list_uri = URI("#{host}/quotes")
list_req = Net::HTTP::Get.new(list_uri.request_uri)
list_req['Accept'] = "application/json"
list_res = get_response(list_uri, list_req)
ids = parse_json(list_res).map{|quote| quote["id"] }

#2. Elegir tres al azar

sample = ids.sample(3)
puts "I've chosen: #{sample.inspect}"

cookie = ""

sample.each do |quote_id|
  quote_uri = URI("#{host}/quotes/#{quote_id}")
  quote_req = Net::HTTP::Get.new(quote_uri.request_uri)
  quote_req['Accept'] = "application/json"
  quote_req['Cookie'] = cookie unless cookie.empty?
  list_res = get_response(quote_uri, quote_req)
  cookie = list_res['Set-Cookie']
end

#Obtener las leídas
#
puts "Quotes I've read:"

read_uri = URI("#{host}/quotes/read")
read_req = Net::HTTP::Get.new(read_uri.request_uri)
read_req['Accept'] = "text/plain"
read_req['Cookie'] = cookie
read_res = get_response(read_uri, read_req)
puts read_res.body

