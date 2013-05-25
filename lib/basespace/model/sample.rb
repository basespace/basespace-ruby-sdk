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
require 'basespace/model/query_parameters'

module Bio
module BaseSpace

# Representation of a BaseSpace Sample object.
class Sample < Model
  def initialize
    @swagger_types = {
      'Name'            => 'str',
      'HrefFiles'       => 'str',
      'DateCreated'     => 'datetime',
      'SampleNumber'    => 'int',
      'Id'              => 'str',
      'Href'            => 'str',
      'UserOwnedBy'     => 'UserCompact',
      'ExperimentName'  => 'str',
      'Run'             => 'RunCompact',
      'HrefGenome'      => 'str',
      'IsPairedEnd'     => 'int',
      'Read1'           => 'int',
      'Read2'           => 'int',
      'NumReadsRaw'     => 'int',
      'NumReadsPF'      => 'int',
      'References'      => 'dict',
    }
    @attributes = {
      'Name'            => nil, # str
      'HrefFiles'       => nil, # str
      'DateCreated'     => nil, # datetime
      'SampleNumber'    => nil, # int
      'Id'              => nil, # str
      'Href'            => nil, # str
      'UserOwnedBy'     => nil, # UserCompact
      'ExperimentName'  => nil, # str
      'Run'             => nil, # RunCompact
      'HrefGenome'      => nil, # str
      'IsPairedEnd'     => nil, # int
      'Read1'           => nil, # int
      'Read2'           => nil, # int
      'NumReadsRaw'     => nil, # int
      'NumReadsPF'      => nil, # int
      'References'      => nil, # dict
    }
  end

  def to_s
    return get_attr('Name')
  end

  # Is called to test if the sample instance has been initialized.
  # 
  # Throws:
  #     ModelNotInitializedError - Indicated the Id variable is not set.
  def is_init
    raise ModelNotInitializedError.new('The sample model has not been initialized yet') unless get_attr('Id')
  end

  #def get_genome
  #  pass
  #end

  # Returns the scope-string to used for requesting BaseSpace access to the sample.
  # 
  # :param scope: The scope type that is request (write|read).
  def get_access_str(scope = 'write')
    is_init
    return scope + ' sample ' + get_attr('Id').to_s
  end

  # Return the AppResults referenced by this sample. Note the returned AppResult objects
  # do not have their "References" field set, to get a fully populate AppResult object
  # you must use getAppResultById in BaseSpaceAPI.
  def get_referenced_app_results(api)
    res = []
    get_attr('References').each do |s|
      if s[:type] == 'AppResult'
        json_app_result = s[:content]
        my_ar = api.serialize_object(json_app_result, 'AppResult')
        res << my_ar
      end
    end
    return res
  end
    
  # Returns a list of File objects
  # 
  # :param api: A BaseSpaceAPI instance
  # :param myQp: Query parameters to sort and filter the file list by.
  def get_files(api, my_qp = {})
    is_init
    query_pars = QueryParameters.new(my_qp)
    return api.get_files_by_sample(get_attr('Id'), query_pars)
  end
end

end # module BaseSpace
end # module Bio

