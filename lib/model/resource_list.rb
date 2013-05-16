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

module Bio
module BaseSpace

class ResourceList
  attr_reader :swagger_types
  attr_accessor :items, :displayed_count, :sort_dir, :total_count, :offset, :sort_by, :limit

  def initialize
    @swagger_types = {
      :items            => 'list<Str>',
      :displayed_count  => 'int',
      :sort_dir         => 'str',
      :total_count      => 'int',
      :offset           => 'int',
      :sort_by          => 'str',
      :limit            => 'int'
    }

    @items              = nil # list<Str>
    @displayed_count    = nil # int
    @sort_dir           = nil # str
    @total_count        = nil # int
    @offset             = nil # int
    @sort_by            = nil # str
    @limit              = nil # int
  end
end

end # module BaseSpace
end # module Bio

