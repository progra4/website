#encoding: utf-8
require 'sinatra'

helpers do
  def link_to type, name
    "<a href=/#{ type == :guide ? "g" : "p"  }/#{name}>#{name.capitalize}</a>"
  end
end

get '/' do
  get_name = ->(filename){ /.*\/(?<name>\w+)\.\w+/.match(filename)[:name]  }
  @presentations = Dir.glob("./views/presentations/*.haml").map(&get_name)
  @guides = Dir.glob("./views/guides/*.md").map(&get_name)
  erb :index
end

get '/g/:title' do |title|
  markdown :"guides/#{title}", layout_engine: :erb, layout: :layout, default_encoding: 'ASCII-8BIT'
end

get '/p/:title' do |title|
  haml :"presentations/#{title}", layout: :slides, layout_engine: :erb, encoding: 'ASCII-8BIT'
end

