require 'bundler'
Bundler.require
require './lib/data_cache'

TYPES = [
  {:id => 0, :name => "application/json"},
  {:id => 1, :name => "application/xml"},
  {:id => 2, :name => "application/octet-stream"}]

cache = DataCache.new("TEST_DATA.LUT")

get '/' do
  erb :index
end

get '/search' do
  @result = nil
  @value = nil
  erb :search
end

get '/search/:key' do
  key = params[:key]
  @result = nil
  @value = cache.select(key)
  unless @value[:value].include?("404")
    @result = "Data has found"
  else
    @value = nil
    @result = "Data has not found"
  end
  erb :search
end

get '/new' do
  @types = TYPES
  erb :new
end

post '/new' do
  @types = TYPES
  key = @params[:key]
  value = @params[:value]
  content_type = TYPES[@params[:type].to_i][:name]
  result = cache.insert(key, value, content_type)
  if result == 200
    @result = "Insert success"
  elsif result == 400
    @result = "Insert failed"
  else
    @result = "Unknown error"
  end
  erb :new
end

get '/delete' do
  erb :delete
end

post '/delete' do
  key = @params[:key]
  if cache.delete(key)
    @result = "Delete success"
  else
    @result = "Delete failed"
  end
  erb :delete
end
