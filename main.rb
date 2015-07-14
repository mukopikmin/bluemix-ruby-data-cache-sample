require 'bundler'
Bundler.require

TYPES = [
  {:id => 0, :name => "application/json"},
  {:id => 1, :name => "application/xml"},
  {:id => 2, :name => "application/octet-stream"}]

get '/' do
  erb :index
end

get '/search' do
  @result = nil
  @value = nil
  erb :search
end

get '/search/:map/:key' do
  map = params[:map]
  key = params[:key]
  cache = BluemixDatacache::Client.new(map)
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
  map = @params[:map]
  key = @params[:key]
  value = @params[:value]
  cache = BluemixDatacache::Client.new(map)
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
  map = @params[:map]
  key = @params[:key]
  cache = BluemixDatacache::Client.new(map)
  if cache.delete(key)
    @result = "Delete success"
  else
    @result = "Delete failed"
  end
  erb :delete
end
