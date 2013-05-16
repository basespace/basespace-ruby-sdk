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

# Representation of a BaseSpace Sample object.
class Sample
  attr_reader :swagger_types
  attr_accessor :name, :href_files, :date_created, :sample_number, :id, :href, :user_owned_by, :experiment_name, :run, :href_genome, :is_paired_end, :read1, :read2, :num_reads_raw, :num_reads_pf, :references

  def initialize
    @swagger_types = {
      :name             => 'str',
      :href_files       => 'str',
      :date_created     => 'datetime',
      :sample_number    => 'int',
      :id               => 'str',
      :href             => 'str',
      :user_owned_by    => 'UserCompact',
      :experiment_name  => 'str',
      :run              => 'RunCompact',
      :href_genome      => 'str',
      :is_paired_end    => 'int',
      :read1            => 'int',
      :read2            => 'int',
      :num_reads_raw    => 'int',
      :num_reads_pf     => 'int',
      :references       => 'dict'
    }

    @name               = nil # str
    @href_files         = nil # str
    @date_created       = nil # datetime
    @sample_number      = nil # int
    @id                 = nil # str
    @href               = nil # str
    @user_owned_by      = nil # UserCompact
    @experiment_name    = nil # str
    @run                = nil # RunCompact
    @href_genome        = nil # str
    @is_paired_end      = nil # int
    @read1              = nil # int
    @read2              = nil # int
    @num_reads_raw      = nil # int
    @num_reads_pf       = nil # int
    @references         = nil # dict
  end

  def to_s
    return @name
  end

  def to_str
    return self.to_s
  end

  # Is called to test if the sample instance has been initialized.
  # 
  # Throws:
  #     ModelNotInitializedError - Indicated the Id variable is not set.
  def is_init
    raise ModelNotInitializedError.new('The sample model has not been initialized yet') unless @id
  end

  #def get_genome
  #  pass
  #end

  # Returns the scope-string to used for requesting BaseSpace access to the sample.
  # 
  # :param scope: The scope type that is request (write|read).
  def get_access_str(scope = 'write')
    is_init
    return scope + ' sample ' + @id.to_s
  end

  # Return the AppResults referenced by this sample. Note the returned AppResult objects
  # do not have their "References" field set, to get a fully populate AppResult object
  # you must use getAppResultById in BaseSpaceAPI.
  def get_referenced_app_results(api)
    res = []
    @references.each do |s|
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
    return api.get_files_by_sample(@id, query_pars)
  end
end

end # module BaseSpace
end # module Bio

