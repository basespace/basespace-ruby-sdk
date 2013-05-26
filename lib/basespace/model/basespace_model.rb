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

require 'basespace/model'

module Bio
module BaseSpace

class BaseSpaceModel < Model
  attr_accessor :api

  def initialize
    # [TODO] This class is not similar to other modles. Need to check if this port is OK.
    @swagger_types = {
      'Id'  => 'str',
    }
    @attributes = {
      'Id'  => nil,
    }
  end

  # [TODO] Do we need this?
  def id
    get_attr('Id')
  end

  def to_s
    is_init
    return get_attr('Id')
  end
  
  def is_init
    return true
  end
  
  def set_api(api)
    @api = api
  end
end

end # module BaseSpace
end # module Bio

