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


# indent 4 -> 2
# self -> @
# CamelCase -> camel_case
# def __init__(self): -> def initialize
# self.swaggerTypes = { "Key":"value" } -> @swagger_types = { :symbol => "value" }
# None = nil
# module Bio::BaseSpace ... end
# __str__(self) -> to_s (return @val.to_s)
# __repr__(self) -> to_str (return self.inspect)
# __fooBar__ -> self.foo_bar (or private?)
# FooBarException -> FooBarError

# 'str' -> String
# 'int' -> Integer
# 'float' -> Float
# 'bool' -> true/false?
# 'list<>' -> Array
# 'dict' -> Hash
# 'file' -> File

