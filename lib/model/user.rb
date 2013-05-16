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

module Bio
module BaseSpace

class User
  attr_reader :swagger_types
  attr_accessor :name, :email, :date_last_active, :gravatar_url, :href_projects, :date_created, :id, :href, :href_runs

  def initialize
    @swagger_types = {
      :name              => 'str',
      :email             => 'str',
      :date_last_active  => 'datetime',
      :gravatar_url      => 'str',
      :href_projects     => 'str',
      :date_created      => 'datetime',
      :id                => 'str',
      :href              => 'str',
      :href_runs         => 'str'
    }

    @name                = nil # str
    @email               = nil # str
    @date_last_active    = nil # datetime
    @gravatar_url        = nil # str
    @href_projects       = nil # str
    @date_created        = nil # datetime
    @id                  = nil # str
    @href                = nil # str
    @href_runs           = nil # str
  end
    
  def to_s
    return "#{@id}: #{@name}"
  end

  def to_str
    return self.to_s
  end

  # Is called to test if the Project instance has been initialized
  # :raise Throws ModelNotInitializedError if the Id variable is not set
  def is_init
    raise ModelNotInitializedError.new('The user model has not been initialized yet') unless @id
  end
  
  def get_projects(api)
    is_init
    return api.get_project_by_user(@id)
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

