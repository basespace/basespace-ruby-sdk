# Copyright 2013 Toshiaki Katayama, Joachim Baran
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

# Resource list model.
class ResourceList < Model

  # Create a new ResourceList instance.
  def initialize
    @swagger_types = {
      'Items'           => 'list<Str>',
      'DisplayedCount'  => 'int',
      'SortDir'         => 'str',
      'TotalCount'      => 'int',
      'Offset'          => 'int',
      'SortBy'          => 'str',
      'Limit'           => 'int',
    }
    @attributes = {
      'Items'           => nil, # list<Str>
      'DisplayedCount'  => nil, # int
      'SortDir'         => nil, # str
      'TotalCount'      => nil, # int
      'Offset'          => nil, # int
      'SortBy'          => nil, # str
      'Limit'           => nil, # int
    }
  end

end

end # module BaseSpace
end # module Bio

