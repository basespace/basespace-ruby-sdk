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

class VariantHeader < Model
  def initialize
    @swagger_types = {
      'Metadata'  => 'dict',
      'Samples'   => 'dict',
      'Legends'   => 'dict',
    }
    @attributes = {
      'Metadata'  => nil, # dict
      'Samples'   => nil, # dict
      'Legends'   => nil, # dict
    }
  end

  def to_s
    return "VariantHeader: SampleCount=#{get_attr('Samples').length}"
  end
end

end # module BaseSpace
end # module Bio

