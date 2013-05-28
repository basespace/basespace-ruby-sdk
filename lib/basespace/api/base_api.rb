# Copyright 2013 Toshiaki Katayama
#
#     Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# 
#     Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'basespace/api/api_client'
require 'basespace/api/basespace_error'

require 'net/https'
require 'uri'

Net::HTTP.version_1_2


module Bio
module BaseSpace

# Parent class for BaseSpaceAPI and BillingAPI objects
class BaseAPI
  def initialize(access_token = nil)
    if  $DEBUG
      $stderr.puts "    # ----- BaseAPI#initialize ----- "
      $stderr.puts "    # caller: #{caller}"
      $stderr.puts "    # access_token: #{access_token}"
      $stderr.puts "    # "
    end
    @api_client = nil
    set_timeout(10)
    set_access_token(access_token)        # logic for setting the access-token 
  end

  def update_access_token(access_token)
    @api_client.api_key = access_token
  end

  def single_request(my_model, resource_path, method, query_params, header_params, post_data = nil, verbose = false, force_post = false, no_api = true)
    # test if access-token has been set
    if not @api_client and no_api
      raise 'Access-token not set, use the "set_access_token"-method to supply a token value'
    end
    # Make the API Call
    if verbose or $DEBUG
      $stderr.puts "    # ----- BaseAPI#single_request ----- "
      $stderr.puts "    # caller: #{caller}"
      $stderr.puts "    # resource_path: #{resource_path}"
      $stderr.puts "    # method: #{method}"
      $stderr.puts "    # query_params: #{query_params}"
      $stderr.puts "    # post_data: #{post_data}"
      $stderr.puts "    # header_params: #{header_params}"
      $stderr.puts "    # force_post: #{force_post}"
      $stderr.puts "    # "
    end
    response = @api_client.call_api(resource_path, method, query_params, post_data, header_params, force_post)
    if verbose or $DEBUG
      $stderr.puts "    # ----- BaseAPI#single_request ----- "
      $stderr.puts "    # response: #{response.inspect}"
      $stderr.puts "    # "
    end
    unless response
      raise 'BaseSpace error: None response returned'
    end

    # throw exception here for various error messages
    if response['ResponseStatus'].has_key?('ErrorCode')
      raise "BaseSpace error: #{response['ResponseStatus']['ErrorCode']}: #{response['ResponseStatus']['Message']}"
    end
     
    # Create output objects if the response has more than one object
    response_object = @api_client.deserialize(response, my_model)
    return response_object.response
  end

  def list_request(my_model, resource_path, method, query_params, header_params, verbose = false, no_api = true)
    # test if access-token has been set
    if not @api_client and no_api
      raise 'Access-token not set, use the "set_access_token"-method to supply a token value'
    end
    
    # Make the API Call
    if verbose or $DEBUG
      $stderr.puts "    # ----- BaseAPI#list_request ----- "
      $stderr.puts "    # caller: #{caller}"
      $stderr.puts "    # Path: #{resource_path}"
      $stderr.puts "    # Pars: #{query_params}"
      $stderr.puts "    # "
    end
    response = @api_client.call_api(resource_path, method, query_params, nil, header_params)  # post_data = nil
    if verbose or $DEBUG
      $stderr.puts "    # ----- BaseAPI#list_request ----- "
      $stderr.puts "    # response: #{response.inspect}"
      $stderr.puts "    # "
    end
    unless response
      raise "BaseSpace Exception: No data returned"
    end
    unless response.kind_of?(Array)  # list
      response = [response]
    end
    response_objects = []
    response.each do |response_object|
      response_objects << @api_client.deserialize(response_object, 'ListResponse')
    end
    
    # convert list response dict to object type
    # TODO check that Response is present -- errors sometime don't include
    #convertet = [@api_client.deserialize(c, my_model) for c in responseObjects[0].convertToObjectList()]
    # [TODO] Check if this port is correct
    convertet = []
    response_objects.each do |c|
      convertet << @api_client.deserialize(c, my_model)
    end
    return convertet
  end

  def hash2urlencode(hash)
    # URI.escape (alias URI.encode) is obsolete since Ruby 1.9.2.
    #return hash.map{|k,v| URI.encode(k.to_s) + "=" + URI.encode(v.to_s)}.join("&")
    return hash.map{|k,v| URI.encode_www_form_component(k.to_s) + "=" + URI.encode_www_form_component(v.to_s)}.join("&")
  end

  def make_curl_request(data, url)
    if $DEBUG
      $stderr.puts "    # ----- BaseAPI#make_curl_request ----- "
      $stderr.puts "    # caller: #{caller}"
      $stderr.puts "    # data: #{data}"
      $stderr.puts "    # url: #{url}"
      $stderr.puts "    # "
    end
    post = hash2urlencode(data)
    uri = URI.parse(url)
    #res = Net::HTTP.post_form(uri, post).body
    http_opts = {}
    if uri.scheme == "https"
      http_opts[:use_ssl] = true
    end
    res = Net::HTTP.start(uri.host, uri.port, http_opts) { |http|
      http.post(uri.path, post)
    }
    obj = JSON.parse(res.body)
    if $DEBUG
      $stderr.puts "    # res: #{res}"
      $stderr.puts "    # obj: #{obj}"
      $stderr.puts "    # "
    end
    if obj.has_key?('error')
      raise "BaseSpace exception: " + obj['error'] + " - " + obj['error_description']
    end
    return obj
  end
    
  def to_s
    return "BaseSpaceAPI instance - using token=#{get_access_token}"
  end
  
  def to_str
    return self.to_s
  end

  # Specify the timeout in seconds for each request made
  #
  # :param time: timeout in second
  def set_timeout(time)
    @timeout = time
    if @api_client
      @api_client.timeout = @timeout
    end
  end
  
  def set_access_token(token)
    @api_client = nil
    if token
      @api_client = APIClient.new(token, @api_server, @timeout)
    end
  end

  # Returns the access-token that was used to initialize the BaseSpaceAPI object.
  def get_access_token
    if @api_client
      return @api_client.api_key
    end
    return ""  # [TODO] Should return nil in Ruby?
  end
  
  # Returns the server uri used by this instance
  def get_server_uri
    return @api_client.api_server
  end
end

end # module BaseSpace
end # module Bio
