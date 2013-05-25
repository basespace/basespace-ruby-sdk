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

require 'basespace/model'

module Bio
module BaseSpace

class GenomeV1 < Model
  def initialize
    @swagger_types = {
      'Source'       => 'str',
      'SpeciesName'  => 'str',
      'Build'        => 'str',
      'Id'           => 'str',
      'Href'         => 'str',
      'DisplayName'  => 'str',
    }
    @attributes = {
      'Source'       => nil, # str
      'SpeciesName'  => nil, # str
      'Build'        => nil, # str
      'Id'           => nil, # str
      'Href'         => nil, # str
      'DisplayName'  => nil, # str
    }
  end

  def to_s
    if get_attr('SpeciesName')
      return get_attr('SpeciesName')
    elsif get_attr('DisplayName')
      return get_attr('DisplayName')
    else
      return "Genome @ #{get_attr('Href')}"
    end
  end
end

end # module BaseSpace
end # module Bio

