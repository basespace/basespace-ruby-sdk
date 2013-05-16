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

# The QueryParameters class can be passed as an optional arguments for a specific sorting of list-responses (such as lists of sample, AppResult, or variants)
class QueryParameters
  attr_reader :swagger_types
  attr_accessor :passed, :required

  # not very strict parameters testing
  LEGAL = {
    :statuses    => [],
    :sort_by     => ['Id', 'Name', 'DateCreated', 'Path', 'Position'],
    :format      => ['txt'],
    :extensions  => [],
    :offset      => [],
    :limit       => [],
    :sort_dir    => ['Asc', 'Desc'],
    :name        => []
  }

  def initialize(pars = {}, required = [:sort_by, :offset, :limit, :sort_dir])
    @passed = { :sort_by => 'Id', :offset => '0', :limit => '100', :sort_dir => 'Asc' }
    pars.each do |k, v|
      @passed[k] = v
    end
    @required = required
  end

  def to_s
    return @passed.to_s
  end

  def to_str
    return self.to_s
  end
    
  def get_parameter_dict
    return @passed
  end
    
  def validate
    @required.each do |p|
      raise UndefinedParameterError.new(p) unless @passed[p]
    end
    @passed.each do |p, v|
      raise UnknownParameterError.new(p) unless LEGAL[p]
      raise IllegalParameterError.new(p, LEGAL[p]) unless (LEGAL[p].length > 0 and ! @passed[p])
    end
  end
end

end # module BaseSpace
end # module Bio

