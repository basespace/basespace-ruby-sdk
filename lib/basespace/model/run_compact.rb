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

# Run compact model.
class RunCompact < Model

  # Create a new RunCompact instance.
  def initialize
    @swagger_types = {
      'DateCreated'     => 'datetime',
      'Id'              => 'str',
      'Href'            => 'str',
      'ExperimentName'  => 'str',
    }
    @attributes = {
      'DateCreated'     => nil, # datetime
      'Id'              => nil, # str
      'Href'            => nil, # str
      'ExperimentName'  => nil, # str
    }
  end

  # Return the experiment name.
  def to_s
    return get_attr('ExperimentName')
  end

  # Returns the scope-string to used for requesting BaseSpace access to the object.
  #
  # +scope+:: The type that is requested (write|read).
  def get_access_str(scope = 'write')
    is_init
    return scope + ' run ' + get_attr('Id').to_s
  end

end

end # module BaseSpace
end # module Bio

