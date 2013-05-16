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

module Bio
module BaseSpace

class VariantHeader
  attr_reader :swagger_types
  attr_accessor :metadata, :samples, :legends

  def initialize
    @swagger_types = {
      :metadata  => 'dict',
      :samples   => 'dict',
      :legends   => 'dict',
    }

    @metadata    = nil # dict
    @samples     = nil # dict
    @legends     = nil # dict
  end

  def to_s
    return "VariantHeader: SampleCount=#{@samples.length}"
  end

  def to_str
    return self.to_s
  end
end

end # module BaseSpace
end # module Bio

