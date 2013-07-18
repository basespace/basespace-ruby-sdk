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

require 'basespace/api/basespace_error'
require 'basespace/model'
require 'basespace/model/query_parameters'

module Bio
module BaseSpace

# Represents a BaseSpace Project object.
class Project < Model

  # Create a new Project instance.
  def initialize
    @swagger_types = {
      'Name'            => 'str',
      'HrefSamples'     => 'str',
      'HrefAppResults'  => 'str',
      'HrefBaseSpaceUI' => 'str',
      'DateCreated'     => 'datetime',
      'Id'              => 'str',
      'Href'            => 'str',
      'UserOwnedBy'     => 'UserCompact',
    }
    @attributes = {
      'Name'            => nil, # str
      'HrefSamples'     => nil, # str
      'HrefAppResults'  => nil, # str
      'HrefBaseSpaceUI' => nil, # str
      'DateCreated'     => nil, # datetime
      'Id'              => nil, # str
      'Href'            => nil, # str
      'UserOwnedBy'     => nil, # UserCompact
    }
  end

  # Returns the name and ID of the project.
  def to_s
    return "#{get_attr('Name')} - id=#{get_attr('Id')}"
  end

  # Test if the Project instance has been initialized.
  # 
  # Throws ModelNotInitializedError, if the object has not been populated yet.
  def is_init
    raise ModelNotInitializedError.new('The project model has not been initialized yet') unless get_attr('Id')
  end
  
  # Returns the scope-string to used for requesting BaseSpace access to the object.
  # 
  # +scope+:: The scope-type that is requested (write|read).
  def get_access_str(scope = 'write')
    is_init
    return scope + ' project ' + get_attr('Id').to_s
  end
  
  # Returns a list of AppResult objects.
  # 
  # +api+:: BaseSpaceAPI instance.
  # +my_qp+:: Query parameters for filtering the returned list.
  # +statuses+:: An optional list of statuses.
  def get_app_results(api, my_qp = {}, statuses = [])
    is_init
    query_pars = QueryParameters.new(my_qp)
    return api.get_app_results_by_project(get_attr('Id'), query_pars, statuses)
  end

  # Returns a list of Sample objects.
  # 
  # +api+:: BaseSpaceAPI instance.
  def get_samples(api)
    is_init
    return api.get_samples_by_project(get_attr('Id'))
  end
  
  # Return a newly created AppResult object.
  # 
  # +api+:: BaseSpaceAPI instance.
  # +name+:: The name of the AppResult.
  # +desc+:: A description of the AppResult.
  # +app_session_id+:: An App session ID.
  # +samples+:: A list of samples.
  def create_app_result(api, name, desc, app_session_id = nil, samples = [])
    is_init
    return api.create_app_result(get_attr('Id'), name, desc, samples, app_session_id)
  end

end

end # module BaseSpace
end # module Bio

