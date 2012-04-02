#encoding: utf-8
require 'sinatra'

get '/' do
  markdown :index, layout: :layout, layout_engine: :erb
end

get '/p/:title' do |title|
  haml :"presentations/#{title}", layout: :slides, layout_engine: :erb
end

