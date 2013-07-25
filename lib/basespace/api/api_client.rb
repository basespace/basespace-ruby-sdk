# Copyright 2012-2013 Joachim Baran, Toshiaki Katayama
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

require 'basespace/api/basespace_error'

require 'net/https'
require 'uri'
require 'json'
require 'date'

Net::HTTP.version_1_2

module Bio
module BaseSpace

# This class provides wrapper methods to the BaseSpace API RESTful interface. It also
# handles serialization and deserialization of objects (Ruby to/from JSON). It is primarily
# used as a helper class for BaseSpaceAPI.
class APIClient
  attr_accessor :api_key, :api_server, :timeout

  # Create a new instance that will carry out REST calls.
  #
  # +access_token+:: Access token that is provided by App triggering.
  # +api_server+:: URI of the BaseSpace API server.
  # +timeout+:: Timeout for REST calls.
  def initialize(access_token = nil, api_server = nil, timeout = 10)
    if $DEBUG
      $stderr.puts "    # ----- BaseAPI#initialize ----- "
      $stderr.puts "    # caller: #{caller}"
      $stderr.puts "    # access_token: #{access_token}"
      $stderr.puts "    # api_server: #{api_server}"
      $stderr.puts "    # timeout: #{timeout}"
      $stderr.puts "    # "
    end
    raise UndefinedParameterError.new('AccessToken') unless access_token
    @api_key = access_token
    @api_server = api_server
    @timeout = timeout
  end

  # POST data to a provided URI.
  #
  # +resource_path+:: URI to which the data should be POSTed.
  # +post_data+:: Hash that contains the data.
  # +headers+:: Header of the POST call.
  # +data+:: (unused; TODO)
  def force_post_call(resource_path, post_data, headers, data = nil)
    # [TODO] Confirm whether we can expect those two parameters are Hash objects:
    # headers = { "key" => "value" }
    # post_data = { "key" => "value" }
    uri = URI.parse(resource_path)
    # If headers are not needed, the following line should be enough:
    # return Net::HTTP.post_form(uri, post_data).body
    http_opts = {}
    if uri.scheme == "https"
      http_opts[:use_ssl] = true
    end
    res = Net::HTTP.start(uri.host, uri.port, http_opts) { |http|
      encoded_data = hash2urlencode(post_data)
      http.post(uri.path, encoded_data, headers)
    }
    return res.body
  end

  # URL encode a Hash of data values.
  #
  # +hash+:: data encoded in a Hash.
  def hash2urlencode(hash)
    # URI.escape (alias URI.encode) is obsolete since Ruby 1.9.2.
    #return hash.map{|k,v| URI.encode(k.to_s) + "=" + URI.encode(v.to_s)}.join("&")
    return hash.map{|k,v| URI.encode_www_form_component(k.to_s) + "=" + URI.encode_www_form_component(v.to_s)}.join("&")
  end

  # Makes a PUT call to a given URI for depositing file contents.
  #
  # +resource_path+:: URI to which the data should be transferred.
  # +post_data+:: (unused; TODO)
  # +headers+:: Header of the PUT call.
  # +trans_file+:: Path to the file that should be transferred.
  def put_call(resource_path, post_data, headers, trans_file)
    return %x(curl -H "x-access-token:#{@api_key}" -H "Content-MD5:#{headers['Content-MD5'].strip}" -T "#{trans_file}" -X PUT #{resource_path})
  end

  # Deserialize a boolean value to a Ruby object.
  #
  # +value+:: serialized representation of the boolean value.
  def bool(value)
    case value
    when nil, false, 0, 'nil', 'false', '0', 'None'
      result = false
    else
      result = true
    end
    return result
  end

  # Carries out a RESTful operation on the BaseSpace API.
  #
  # TODO Need check. Logic in this method is rather complicated...
  #
  # +resource_path+:: URI that should be used for the API call.
  # +method+:: HTTP method for the rest call (GET, POST, DELETE, etc.)
  # +query_params+:: query parameters that should be sent along to the API.
  # +post_data+:: Hash that contains data to be transferred.
  # +header_params+:: Additional settings that should be transferred in the HTTP header.
  # +force_post+:: Truth value that indicates whether a POST should be forced.
  def call_api(resource_path, method, query_params, post_data, header_params = nil, force_post = false)
    url = @api_server + resource_path

    headers = header_params.dup
    headers['Content-Type'] = 'application/json' if not headers.has_key?('Content-Type') and not method == 'PUT'
    # include access token in header
    headers['Authorization'] = "Bearer #{@api_key}"

    uri = request = response = data = cgi_params = nil

    if query_params
      # Need to remove None (in Python, nil in Ruby) values, these should not be sent
      sent_query_params = {}
      query_params.each do |param, value|
        sent_query_params[param] = value if bool(value)
      end
      cgi_params = hash2urlencode(sent_query_params)
    end

    if $DEBUG
      $stderr.puts "    # ----- APIClient#call_api ----- "
      $stderr.puts "    # caller: #{caller}"
      $stderr.puts "    # url: #{url}"
      $stderr.puts "    # method: #{method}"
      $stderr.puts "    # headers: #{headers}"
      $stderr.puts "    # cgi_params: #{cgi_params}"
      $stderr.puts "    # post_data: #{post_data}"
      $stderr.puts "    # "
    end

    case method
    when 'GET'
      if cgi_params
        url += "?#{cgi_params}"
      end
      # [TODO] confirm this works or not
      #request = urllib2.Request(url, headers)
      uri = URI.parse(url)
      request = Net::HTTP::Get.new(uri, headers)
    when 'POST', 'PUT', 'DELETE'
      if cgi_params
        force_post_url = url 
        url += "?#{cgi_params}"
      end
      if post_data
        # [TODO] Do we need to skip String, Integer, Float and bool in Ruby?
        data = post_data.to_json # if not [str, int, float, bool].include?(type(post_data))
      end
      if force_post
        response = force_post_call(force_post_url, sent_query_params, headers)
      else
        data = '\n' if data and data.empty? # temp fix, in case is no data in the file, to prevent post request from failing
        # [TODO] confirm this works or not
        #request = urllib2.Request(url, headers, data)#, @timeout)
        uri = URI.parse(url)
        request = Net::HTTP::Post.new(uri.path, headers)
      end
      if ['PUT', 'DELETE'].include?(method) # urllib doesnt do put and delete, default to pycurl here
        response = put_call(url, query_params, headers, data)
        response = response.split.last
      end
    else
      raise "Method #{method} is not recognized."
    end

    # Make the request, request may raise 403 forbidden, or 404 non-response
    if not force_post and not ['PUT', 'DELETE'].include?(method)  # the normal case
      # puts url
      # puts request
      # puts "request with timeout=#{@timeout}"
      # [TODO] confirm this works or not
      #response = urllib2.urlopen(request, @timeout).read()
      http_opts = {}
      if uri.scheme == "https"
        http_opts[:use_ssl] = true
      end
      response = Net::HTTP.start(uri.host, uri.port, http_opts) { |http|
        http.request(request)
      }
    end
            
    begin
      data = JSON.parse(response.body)
    rescue => err
      $stderr.puts "    # ----- APIClient#call_api ----- "
      $stderr.puts "    # Error: #{err}"
      $stderr.puts "    # "
      data = nil
    end
    return data
  end

  # Serialize a list to a CSV string, if necessary.
  #
  # +obj+:: Data object to be serialized.
  def to_path_value(obj)
    if obj.kind_of?(Array)
      return obj.join(',')
    else
      return obj
    end
  end

  # Deserialize a JSON string into an object.
  #
  # +obj+:: String or object to be deserialized.
  # +obj_class+:: Class literal for deserialzied object, or string of class name.
  def deserialize(obj, obj_class)
    case obj_class.downcase
    when 'str'
      return obj.to_s
    when 'int'
      return obj.to_i
    when 'float'
      return obj.to_f
    when 'bool'
      return bool(obj)
    when 'file'
      # Bio::BaseSpace::File
      instance = File.new 
    else
      # models in BaseSpace
      klass = ::Bio::BaseSpace.const_get(obj_class)
      instance = klass.new
    end

    if $DEBUG
      $stderr.puts "    # ----- APIClient#deserialize ----- "
      $stderr.puts "    # caller: #{caller}"
      $stderr.puts "    # obj_class: #{obj_class}"
      $stderr.puts "    # obj: #{obj}"  # JSON.pretty_generate(obj)
      $stderr.puts "    # "
    end

    instance.swagger_types.each do |attr, attr_type|
      if obj.has_key?(attr) or obj.has_key?(attr.to_s)
        if $DEBUG
          $stderr.puts "    # # ----- APIClient#deserialize/swagger_types ----- "
          $stderr.puts "    # # attr: #{attr}"
          $stderr.puts "    # # attr_type: #{attr_type}"
          $stderr.puts "    # # value: #{obj[attr]}"
          $stderr.puts "    # # "
        end
        value = obj[attr]
        case attr_type.downcase
        when 'str'
          instance.set_attr(attr, value.to_s)
        when 'int'
          instance.set_attr(attr, value.to_i)
        when 'float'
          instance.set_attr(attr, value.to_f)
        when 'datetime'
          instance.set_attr(attr, DateTime.parse(value))
        when 'bool'
          instance.set_attr(attr, bool(value))
        when /list</
          sub_class = attr_type[/list<(.*)>/, 1]
          sub_values = []
          value.each do |sub_value|
            sub_values << deserialize(sub_value, sub_class)
          end
          instance.set_attr(attr, sub_values)
        when 'dict'  # support for parsing dictionary
          if $DEBUG
            $stderr.puts "    # # # ----- APIClient#deserialize/swagger_types/dict ----- "
            $stderr.puts "    # # # dict: #{value}"
            $stderr.puts "    # # # "
          end
          # [TODO] May need to convert value -> Hash (check in what format the value is passed)
          instance.set_attr(attr, value)
        else
          if $DEBUG
            # print "recursive call w/ " + attrType
            $stderr.puts "    # # # ----- APIClient#deserialize/swagger_types/recursive call ----- "
            $stderr.puts "    # # # attr: #{attr}"
            $stderr.puts "    # # # attr_type: #{attr_type}"
            $stderr.puts "    # # # value: #{value}"
            $stderr.puts "    # # # "
          end
          instance.set_attr(attr, deserialize(value, attr_type))
        end
      end
    end
    if $DEBUG
      $stderr.puts "    # # ----- APIClient#deserialize/instance ----- "
      $stderr.puts "    # # instance: #{instance.attributes.inspect}"
      $stderr.puts "    # # "
    end
    return instance
  end

end

end # module BaseSpace
end # module Bio

