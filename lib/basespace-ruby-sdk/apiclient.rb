# Copyright 2012-2013 Joachim Baran, Raoul Bonnal, Toshiaki Katayama, Francesco Strozzi
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

#import sys
#import os
#import re
#import urllib
#import urllib2
#import pycurl
#import io
#import cStringIO
#import json
#from subprocess import *
#import subprocess
#from pprint import pprint

#sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../')
#from model import *

require 'basespace-ruby-sdk/basespaceerror'

module BaseSpaceRuby

class APIClient
    def initialize(access_token = nil, api_server = nil, timeout = 10)
        raise BaseSpaceRuby::UndefinedParameterError('AccessToken') unless access_token
        @api_key = access_token
        @api_server = api_server
        @timeout = timeout
    end

    #  For forcing a post request using pycurl
    # TODO
    def self.force_post_call(resource_path, post_data, headers, data = nil)
        post_data = post_data.map { |p| [ p, post_data[p] ] }
        header_prep = headers.keys.map { |k| "#{k}:#{headers[k]}" }
        post =  urllib.urlencode(post_data)
        response = cStringIO.StringIO()
        c = pycurl.Curl()
        c.setopt(pycurl.URL,resource_path + '?' + post)
        c.setopt(pycurl.HTTPHEADER, header_prep)
        c.setopt(pycurl.POST, 1)
        c.setopt(pycurl.POSTFIELDS, post)
        c.setopt(c.WRITEFUNCTION, response.write)
        c.perform()
        c.close()
        return response.getvalue()
    end

    # TODO
    def self.putCall(resource_path, post_data, headers, trans_file)
        header_prep = headers.keys.map { |k| "#{k}:#{headers[k]}" }
        cmd = "curl -H \"x-access-token:#{@api_key}\" -H \"Content-MD5:#{headers['Content-MD5'].strip}\" -T \"#{trans_file}\" -X PUT #{resource_path}"
        ##cmd = data +'|curl -H "x-access-token:' + self.apiKey + '" -H "Content-MD5:' + headers['Content-MD5'].strip() +'" -d @- -X PUT ' + resourcePath
        p = Popen(cmd, shell = true, stdin = PIPE, stdout = PIPE, stderr = STDOUT, close_fds = true)
        output = p.stdout.read()
        return output
    end

    # TODO
    def callAPI(resource_path, method, query_params, post_data, header_params = nil, force_post = 0)
        url = @api_server + resource_path
        headers = {}
        if header_params then
            for param, value in headerParams.iteritems() do
                headers[param] = value
            end
        end

        headers['Content-Type'] = 'application/json' if not headers.has_key?('Content-Type') and not method == 'PUT'
        headers['Authorization'] = "Bearer #{@api_key}"
        
        data = None
        if method == 'GET' then
            if query_params then
                # Need to remove None values, these should not be sent
                sent_query_params = {}
                for param, value in query_params.iteritems() do
                    sent_query_params[param] = value if value
                end
                url = url + '?' + urllib.urlencode(sentQueryParams)
            end
            request = urllib2.Request(url=url, headers=headers)
        elsif ['POST', 'PUT', 'DELETE'].include?(method) then
            if query_params then
                # Need to remove None values, these should not be sent
                sent_query_params = {}
                for param, value in query_params.iteritems() do
                    sent_query_params[param] = value if value
                end
                force_post_url = url 
                url = url + '?' + urllib.urlencode(sent_query_params)
            end
            data = postData
            if data then
                data = json.dumps(post_data) if not [str, int, float, bool].include?(type(postData))
            end
            if not forcePost then
                data = '\n' if data and not len(data) # temp fix, in case is no data in the file, to prevent post request from failing
                request = urllib2.Request(url=url, headers=headers, data=data)#,timeout=self.timeout)
            else                                    # use pycurl to force a post call, even w/o data
                response = self.__forcePostCall__(forcePostUrl,sentQueryParams,headers)
            end
            if ['PUT', 'DELETE'].include?(method) then #urllib doesnt do put and delete, default to pycurl here
                response = put_call(url, query_params, headers, data)
                response =  response.split()[-1]
            end
                
        else
            raise Exception('Method ' + method + ' is not recognized.')
        end

        # Make the request, request may raise 403 forbidden, or 404 non-response
        if not forcePost and not ['PUT', 'DELETE'].include?(method) then                   # the normal case
#            print url
            #print request
#            print "request with timeout=" + str(self.timeout)
            response = urllib2.urlopen(request,timeout=self.timeout).read()
        end
            
        begin
            data = json.loads(response)
        rescue Error => err
            err
            data = nil
        end
        return data
    end

    # Serialize a list to a CSV string, if necessary.
    #
    # ++obj++: data object to be serialized
    # TODO
    def to_path_value(obj)
        if type(obj) == list then
            return obj.join(',')
        else
            return obj
        end
    end

    # Derialize a JSON string into an object.
    #
    # ++obj++: string or object to be deserialized
    # ++objClass++: class literal for deserialzied object, or string of class name
    # TODO
    def deserialize(obj, obj_class)
### TODO Syntax snip. I got to here so far. -- Joachim
        if type(obj_class) == str then
            begin
                if not str(obj_class) == 'File' then                # Hack to avoid native python-type 'file' (non-capital 'f')
                    obj_class = eval(obj_class.lower())
                else
                    obj_class = eval(obj_class + '.' + obj_class)
                end
            rescue NameError  # not a native type, must be model class
                obj_class = eval(obj_class + '.' + obj_class)
            end
        end

        return objClass(obj) if [str, int, float, bool].include?(obj_class) 
        instance = obj_class()
        
        for attr, attrType in instance.swaggerTypes.iteritems() do
            if obj.has_key?(attr) then
#                print '@@@@ ' + str(obj)
#                print '@@@@ ' + str(attr)
#                print '@@@@ ' + str(attrType)
                value = obj[attr]
#                print value
                if ['str', 'int', 'float', 'bool'].include?(attr_type) then
                    attrType = eval(attrType)
                    begin
                        value = attrType(value)
                    rescue UnicodeEncodeError
                        value = unicode(value)
                    end
                    setattr(instance, attr, value)
                elsif attr_type.include?('list<')
                    match = re.match('list<(.*)>', attrType)
                    subClass = match.group(1)
                    subValues = []

                    for subValue in value do
                        subValues.append(self.deserialize(subValue, subClass))
                    end
                    setattr(instance, attr, subValues)
                elsif attrType == 'dict' then                                    # support for parsing dictionary
#                    pprint(value)                   
                    setattr(instance, attr,value)
                else
#                    print "recursive call w/ " + attrType
                    setattr(instance, attr, self.deserialize(value,attrType))
                end
            end
        end

        return instance
    end

end

end

