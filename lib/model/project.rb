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

require 'api/basespace_error'
require 'model/query_parameters'

module Bio
module BaseSpace

# Represents a BaseSpace Project object.
class Project
  attr_reader :swagger_types
  attr_accessor :name, :href_samples, :href_app_results, :date_created, :id, :href, :user_owned_by

  def initialize
    @swagger_types = {
      :name              => 'str',
      :href_samples      => 'str',
      :href_app_results  => 'str',
      :date_created      => 'datetime',
      :id                => 'str',
      :href              => 'str',
      :user_owned_by     => 'UserCompact'
    }

    @name                = nil # str
    @href_samples        = nil # str
    @href_app_results    = nil # str
    @date_created        = nil # str
    @id                  = nil # str
    @href                = nil # str
    @user_owned_by       = nil # UserCompact
  end

  def to_s
    return "#{@name} - id=#{@id}"
  end

  def to_str
    return self.to_s
  end

  # Is called to test if the Project instance has been initialized.
  # 
  # Throws:
  #     ModelNotInitializedError - Indicates the object has not been populated yet.
  def is_init
    raise ModelNotInitializedError.new('The project model has not been initialized yet') unless @id
  end
  
  # Returns the scope-string to used for requesting BaseSpace access to the object
  # 
  # :param scope: The scope-type that is request (write|read)
  def get_access_str(scope = 'write')
    is_init
    return scope + ' project ' + @id.to_s
  end
  
  # Returns a list of AppResult objects.
  # 
  # :param api: An instance of BaseSpaceAPI
  # :param statuses: An optional list of statuses
  def get_app_results(api, my_qp = {}, statuses = [])
    is_init
    query_pars = QueryParameters.new(my_qp)
    return api.get_app_results_by_project(@id, query_pars, statuses)
  end

  # Returns a list of Sample objects.
  # 
  # :param api: An instance of BaseSpaceAPI
  def get_samples(api)
    is_init
    return api.get_samples_by_project(@id)
  end
  
  # Return a newly created app result object
  # 
  # :param api: An instance of BaseSpaceAPI
  # :param name: The name of the app result
  # :param desc: A describtion of the app result
  def create_app_result(api, name, desc, app_session_id = nil, samples = [])
    is_init
    return api.create_app_result(@id, name, desc, app_session_id, samples)
  end
end

end # module BaseSpace
end # module Bio

