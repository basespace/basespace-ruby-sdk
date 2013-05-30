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

module Bio
module BaseSpace

# The QueryParameters class can be passed as an optional arguments for a specific sorting of list-responses (such as lists of sample, AppResult, or variants)
class QueryParameters
  attr_accessor :passed, :required

  # not very strict parameters testing
  LEGAL = {
    'Statuses'    => [],
    'SortBy'      => ['Id', 'Name', 'DateCreated', 'Path', 'Position'],
    'Format'      => ['txt'],
    'Extensions'  => [],
    'Offset'      => [],
    'Limit'       => [],
    'SortDir'     => ['Asc', 'Desc'],
    'Name'        => [],
  }

  def initialize(pars = {}, required = ['SortBy', 'Offset', 'Limit', 'SortDir'])
    @passed = {
      'SortBy'  => 'Id',
      'Offset'  => '0',    # [TODO] .to_i?
      'Limit'   => '100',  # [TODO] .to_i?
      'SortDir' => 'Asc',
    }
    pars.each do |k, v|
      @passed[k] = v
    end
    @required = required
  end

  def to_s
    return @passed.to_s
  end

  def to_str
    return self.inspect
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
      raise IllegalParameterError.new(p, LEGAL[p]) if (LEGAL[p].length > 0 and ! LEGAL[p].include?(@passed[p]))
    end
  end
end

end # module BaseSpace
end # module Bio

