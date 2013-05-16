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

require 'api/api_client'
require 'api/base_api'
#require 'api/billing_api'
require 'api/basespace_api'
require 'api/basespace_error'

require 'model/app_result'
require 'model/app_result_response'
require 'model/app_session'
require 'model/app_session_compact'
require 'model/app_session_launch_object'
require 'model/app_session_response'
require 'model/application'
require 'model/application_compact'
require 'model/basespace_model'
require 'model/coverage'
require 'model/coverage_meta_response'
require 'model/coverage_metadata'
require 'model/coverage_response'
require 'model/file'
require 'model/file_response'
require 'model/genome_response'
require 'model/genome_v1'
require 'model/list_response'
#require 'model/multipart_upload'
require 'model/product'
require 'model/project'
require 'model/project_response'
require 'model/purchase'
require 'model/purchase_response'
require 'model/purchased_product'
require 'model/query_parameters'
require 'model/query_parameters_purchased_product'
require 'model/refund_purchase_response'
require 'model/resource_list'
require 'model/response_status'
require 'model/run_compact'
require 'model/sample'
require 'model/sample_response'
require 'model/user'
require 'model/user_compact'
require 'model/user_response'
require 'model/variant'
require 'model/variant_header'
require 'model/variant_info'
require 'model/variants_header_response'


# indent 4 -> 2
# self -> @
# CamelCase -> camel_case
# def __init__(self): -> def initialize
# self.swaggerTypes = { "Key":"value" } -> @swagger_types = { :symbol => "value" }
# None = nil
# module Bio::BaseSpace ... end
# __str__(self) -> to_s  (self.to_s?)
# __repr__(self) -> to_str (self.to_str?) [TODO] should return self.inspect
# __fooBar__ -> self.foo_bar (or private?)
# FooBarException -> FooBarError

# 'str' -> String
# 'int' -> Integer
# 'float' -> Float
# 'bool' -> true/false?
# 'list<>' -> Array
# 'dict' -> Hash
# 'file' -> File

