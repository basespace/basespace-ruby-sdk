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

class RunCompact
  attr_reader :swagger_types
  attr_accessor :date_created, :id, :href, :experiment_name

  def initialize
    @swagger_types = {
      :date_created     => 'str',
      :id               => 'str',
      :href             => 'str',
      :experiment_name  => 'str'
    }

    @date_created       = nil # str
    @id                 = nil # str
    @href               = nil # str
    @experiment_name    = nil # str
  end

  def to_s
    return @experiment_name
  end

  def to_str
    return self.to_s
  end

  # Returns the scope-string to used for requesting BaseSpace access to the object
  # :param scope: The type that is request (write|read)
  def get_access_str(scope = 'write')
    is_init
    return scope + ' run ' + @id.to_s
  end
end

end # module BaseSpace
end # module Bio

