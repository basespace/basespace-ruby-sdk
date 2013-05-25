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

require 'basespace/api/basespace_error'
require 'basespace/model'

module Bio
module BaseSpace

class User < Model
  def initialize
    @swagger_types = {
      'Name'            => 'str',
      'Email'           => 'str',
      'DateLastActive'  => 'datetime',
      'GravatarUrl'     => 'str',
      'HrefProjects'    => 'str',
      'DateCreated'     => 'datetime',
      'Id'              => 'str',
      'Href'            => 'str',
      'HrefRuns'        => 'str',
    }
    @attributes = {
      'Name'            => nil, # str
      'Email'           => nil, # str
      'DateLastActive'  => nil, # datetime
      'GravatarUrl'     => nil, # str
      'HrefProjects'    => nil, # str
      'DateCreated'     => nil, # datetime
      'Id'              => nil, # str
      'Href'            => nil, # str
      'HrefRuns'        => nil, # str
    }
  end
    
  def to_s
    return "#{get_attr('Id')}: #{get_attr('Name')}"
  end

  # Is called to test if the Project instance has been initialized
  # :raise Throws ModelNotInitializedError if the Id variable is not set
  def is_init
    raise ModelNotInitializedError.new('The user model has not been initialized yet') unless get_attr('Id')
  end
  
  def get_projects(api)
    is_init
    return api.get_project_by_user(get_attr('Id'))
  end

  # Returns a list of the accessible run for the user 
  # :param api: An instance of BaseSpaceAPI
  def get_runs(api)
    is_init
    return api.get_accessible_runs_by_user('current')
  end
end

end # module BaseSpace
end # module Bio

