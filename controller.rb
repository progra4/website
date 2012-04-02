#encoding: utf-8
require 'sinatra'

get '/' do
  markdown :index, layout: :layout, layout_engine: :erb
end

