require 'json'
require 'base64'
require 'uri'
require 'net/http'

class DataCache

  def initialize(map)
    credential = JSON.parse(ENV["VCAP_SERVICES"])["DataCache-1.0"][0]["credentials"]
    auth = "#{credential['username']}:#{credential['password']}"
    @api = credential['restResource']
    @auth = "Basic #{Base64.strict_encode64(auth)}"
    @map = map
  end

  def insert(key, value, content_type)
    begin
      uri = URI.parse("#{@api}/#{URI.escape(@map)}/#{URI.escape(key)}")
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new(uri.path)
        request["Content-type"] = content_type
        request["Authorization"] = @auth
        request["rejectUnauthorized"] = false
        request["agent"] = false
        request.body = value
        response = http.request(request)
        return response.code.to_i
      end
    rescue
      return nil
    end
  end

  def select(key)
    begin
      uri = URI.parse("#{@api}/#{URI.escape(@map)}/#{URI.escape(key)}")
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.path)
        request["Authorization"] = @auth
        request["rejectUnauthorized"] = false
        request["agent"] = false
        response = http.request(request)
        return {:key => key, :value => response.body, :type => response['content-type']}
      end
    rescue
      return nil
    end
  end

  def delete(key)
    begin
      uri = URI.parse("#{@api}/#{URI.escape(@map)}/#{URI.escape(key)}")
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Delete.new(uri.path)
        request["Authorization"] = @auth
        request["rejectUnauthorized"] = false
        request["agent"] = false
        response = http.request(request)
        return true
      end
    rescue
      return false
    end
  end

end
