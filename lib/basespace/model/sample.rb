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

# Representation of a BaseSpace Sample object.
class Sample < Model

  # Return a new Sample instance.
  def initialize
    @swagger_types = {
      'HrefGenome'      => 'str',
      'SampleNumber'    => 'int',
      'ExperimentName'  => 'str',
      'HrefFiles'       => 'str',
      'AppSession'      => 'dict',
      'IsPairedEnd'     => 'bool',
      'Read1'           => 'int',
      'Read2'           => 'int',
      'NumReadsRaw'     => 'int',
      'NumReadsPF'      => 'int',
      'Id'              => 'str',
      'Href'            => 'str',
      'UserOwnedBy'     => 'UserCompact',
      'Name'            => 'str',
      'SampleId'        => 'str',
      'Status'          => 'str',
      'StatusSummary'   => 'str',
      'DateCreated'     => 'datetime',
      'References'      => 'dict', # NOTE Is this correct? Because references is a list.
      'Run'             => 'RunCompact',
    }
    @attributes = {
      'Name'            => nil, # str
      'HrefFiles'       => nil, # str
      'AppSession'      => nil, # dict
      'DateCreated'     => nil, # datetime
      'SampleNumber'    => nil, # int
      'Id'              => nil, # str
      'Href'            => nil, # str
      'UserOwnedBy'     => nil, # UserCompact
      'ExperimentName'  => nil, # str
      'Run'             => nil, # RunCompact
      'HrefGenome'      => nil, # str
      'IsPairedEnd'     => nil, # bool
      'Read1'           => nil, # int
      'Read2'           => nil, # int
      'NumReadsRaw'     => nil, # int
      'NumReadsPF'      => nil, # int
      'References'      => nil, # dict
      'SampleId'        => nil, # dict
      'Status'          => nil, # dict
      'StatusSummary'   => nil, # dict
    }
  end

  # Return the name of the sample.
  def to_s
    return get_attr('Name')
  end

  # Test if the sample instance has been initialized.
  # 
  # Throws ModelNotInitializedError, if the Id variable is not set.
  def is_init
    raise ModelNotInitializedError.new('The sample model has not been initialized yet') unless get_attr('Id')
  end

  #def get_genome
  #  pass
  #end

  # Returns the scope-string to be used for requesting BaseSpace access to the sample.
  # 
  # +scope+:: The scope type that is requested (write|read).
  def get_access_str(scope = 'write')
    is_init
    return scope + ' sample ' + get_attr('Id').to_s
  end

  # Return the AppResults referenced by this sample.
  #
  # Note: the returned AppResult objects do not have their "References" field set,
  # to get a fully populate AppResult object you must use get_app_result_by_id in BaseSpaceAPI.
  #
  # +api+:: BaseSpaceAPI instance.
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
    
  # Returns a list of File objects.
  # 
  # +api+:: BaseSpaceAPI instance.
  # +my_qp+:: Query parameters to sort and filter the file list by.
  def get_files(api, my_qp = {})
    is_init
    query_pars = QueryParameters.new(my_qp)
    return api.get_files_by_sample(get_attr('Id'), query_pars)
  end

end

end # module BaseSpace
end # module Bio

