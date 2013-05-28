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

# Still need to check [TODO] sections

require 'basespace/api/api_client'
require 'basespace/api/base_api'
require 'basespace/api/billing_api'
require 'basespace/api/basespace_api'
require 'basespace/api/basespace_error'

require 'basespace/model'
require 'basespace/model/app_result'
require 'basespace/model/app_result_response'
require 'basespace/model/app_session'
require 'basespace/model/app_session_compact'
require 'basespace/model/app_session_launch_object'
require 'basespace/model/app_session_response'
require 'basespace/model/application'
require 'basespace/model/application_compact'
require 'basespace/model/basespace_model'
require 'basespace/model/coverage'
require 'basespace/model/coverage_meta_response'
require 'basespace/model/coverage_metadata'
require 'basespace/model/coverage_response'
require 'basespace/model/file'
require 'basespace/model/file_response'
require 'basespace/model/genome_response'
require 'basespace/model/genome_v1'
require 'basespace/model/list_response'
#require 'basespace/model/multipart_upload'
require 'basespace/model/product'
require 'basespace/model/project'
require 'basespace/model/project_response'
require 'basespace/model/purchase'
require 'basespace/model/purchase_response'
require 'basespace/model/purchased_product'
require 'basespace/model/query_parameters'
require 'basespace/model/query_parameters_purchased_product'
require 'basespace/model/refund_purchase_response'
require 'basespace/model/resource_list'
require 'basespace/model/response_status'
require 'basespace/model/run_compact'
require 'basespace/model/sample'
require 'basespace/model/sample_response'
require 'basespace/model/user'
require 'basespace/model/user_compact'
require 'basespace/model/user_response'
require 'basespace/model/variant'
require 'basespace/model/variant_header'
require 'basespace/model/variant_info'
require 'basespace/model/variants_header_response'

require 'json'

module Bio
  module BaseSpace
    def self.load_credentials
      filename = "credentials.json"
      filepath1 = ::File.join('.', filename)
      filepath2 = ::File.join(::File.dirname(__FILE__), filename)  # [TODO] This can be lib/ instead of examples/
      if ::File.exists?(filepath1)
        jsonfile = filepath1
      elsif ::File.exists?(filepath2)
        jsonfile = filepath2
      end
      if jsonfile
        json = JSON.parse(::File.read(jsonfile))
        if $DEBUG
          $stderr.puts "    # ----- Bio::BaseSpace.load_credientials ----- "
          $stderr.puts "    # Loaded credentials from #{jsonfile}"
          $stderr.puts "    # "
        end
      else
        json = nil
        $stderr.puts "    # ----- Bio::BaseSpace.load_credientials ----- "
        $stderr.puts "    # You can put your credentials for the BaseSpace in the"
        $stderr.puts "    #   #{filepath1}"
        $stderr.puts "    # or"
        $stderr.puts "    #   #{filepath2}"
        $stderr.puts "    # file in the following format:"
        hash = {
          'client_id'       => '<your client id>',
          'client_secret'   => '<your client secret>',
          'access_token'    => '<your access token>',
          'app_session_id'  => '<app session id>',
          'basespace_url'   => 'https://api.basespace.illumina.com/',
          'api_version'     => 'v1pre3',
        }
        $stderr.puts JSON.pretty_generate(JSON.parse(hash.to_json))
      end
      return json
    end
  end # BaseSpace
end # Bio


# indent 4 -> 2
# CamelCase -> camel_case
# def __init__(self): -> def initialize
# self.swaggerTypes = { "Key":"value" } -> @swagger_types = { "Key" => "value" }
# self.Value -> @attributes = {'Value' => value}, get_attr('Value'), set_attr('Value', value)
# None = nil
# module Bio::BaseSpace ... end
# __str__(self) -> to_s (return @val.to_s)
# __repr__(self) -> to_str (return self.inspect) or self.attributes.inspect for attribute values
# __fooBar__ -> self.foo_bar (or private method?)
# FooBarException -> FooBarError

# 'str' -> String
# 'int' -> Integer
# 'float' -> Float
# 'bool' -> true/false?
# 'list<>' -> Array
# 'dict' -> Hash
# 'file' -> File

