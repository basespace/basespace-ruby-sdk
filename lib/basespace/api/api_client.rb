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

class APIClient
  attr_accessor :api_key, :api_server, :timeout

  def initialize(access_token = nil, api_server = nil, timeout = 10)
    raise UndefinedParameterError.new('AccessToken') unless access_token
    @api_key = access_token
    @api_server = api_server
    @timeout = timeout
  end

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

  def hash2urlencode(hash)
    return hash.map{|k,v| URI.encode(k.to_s) + "=" + URI.encode(v.to_s)}.join("&")
  end

  def put_call(resource_path, post_data, headers, trans_file)
    return %x(curl -H "x-access-token:#{@api_key}" -H "Content-MD5:#{headers['Content-MD5'].strip}" -T "#{trans_file}" -X PUT #{resource_path})
  end

  def bool(value)
    case value
    when nil, false, 0, 'nil', 'false', '0', 'None'
      result = false
    else
      result = true
    end
    return result
  end

  # [TODO] Need check. Logic in this method is too ugly to understand....
  def call_api(resource_path, method, query_params, post_data, header_params = nil, force_post = false)
    url = @api_server + resource_path

    headers = header_params.dup
    headers['Content-Type'] = 'application/json' if not headers.has_key?('Content-Type') and not method == 'PUT'
    # include access token in header
    headers['Authorization'] = "Bearer #{@api_key}"

    uri = request = response = data = cgi_params = nil

    if query_params
      # Need to remove None (in Python, nil in Ruby?) values, these should not be sent
      sent_query_params = {}
      query_params.each do |param, value|
        sent_query_params[param] = value if bool(value)  # [TODO] confirm this works or not
      end
      cgi_params = hash2urlencode(sent_query_params)
    end

    case method
    when 'GET'
      if cgi_params
        url += "?#{cgi_params}"
      end
      # [TODO] confirm this works or not
      #request = urllib2.Request(url, headers)
      uri = URI.parse(url)
      request = Net::HTTP::Get.new(uri.path)
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
        request = Net::HTTP::Post.new(uri.path)
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
    rescue Error => err
      err
      data = nil
    end
    return data
  end

  # Serialize a list to a CSV string, if necessary.
  #
  # Args:
  #   obj -- data object to be serialized
  # Returns:
  #   string -- json serialization of object
  def to_path_value(obj)
    if obj.kind_of?(Array)
      return obj.join(',')
    else
      return obj
    end
  end

  # Derialize a JSON string into an object.
  #
  # Args:
  #     obj -- string or object to be deserialized
  #     obj_class -- class literal for deserialzied object, or string of class name
  # Returns:
  #     object -- deserialized object
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
    else # models in BaseSpace
      klass = Object.const_get(obj_class)
      instance = klass.new
    end

    instance.swagger_types.each do |attr, attr_type|
      if obj.has_key?(attr) or obj.has_key?(attr.to_s)
        # puts '@@@@ ' + obj.inspect
        # puts '@@@@ ' + attr.to_s
        # puts '@@@@ ' + attr_type.to_s
        value = obj[attr]
        # puts value
        case attr_type.downcase
        when 'str'
          instance.__send__("#{attr}=", value.to_s)
        when 'int'
          instance.__send__("#{attr}=", value.to_i)
        when 'float'
          instance.__send__("#{attr}=", value.to_f)
        when 'datetime'
          instance.__send__("#{attr}=", DateTime.parse(value))
        when 'bool'
          instance.__send__("#{attr}=", bool(value))
        when /list</
          sub_class = attr_type[/list<(.*)>/, 1]
          sub_values = []
          value.each do |sub_value|
            sub_values << deserialize(sub_value, sub_class)
          end
          instance.__send__("#{attr}=", sub_values)
        when 'dict'  # support for parsing dictionary
          # puts value.inspect
          # [TODO] May need to convert value -> Hash (check in what format the value is passed)
          instance.__send__("#{attr}=", value)
        else
          # print "recursive call w/ " + attrType
          instance.__send__("#{attr}=", deserialize(value, attr_type))
        end
      end
    end
    return instance
  end

end

end # module BaseSpace
end # module Bio

