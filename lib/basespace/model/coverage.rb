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

class Coverage < Model
  def initialize
    @swagger_types = {
      'Chrom'         => 'str',
      'BucketSize'    => 'int',
      'MeanCoverage'  => 'list<int>',
      'EndPos'        => 'int',
      'StartPos'      => 'int',
    }
    @attributes = {
      'Chrom'         => nil, # str
      'BucketSize'    => nil, # int Each returned number will represent coverage of this many bases.
      'MeanCoverage'  => nil, # list<Str>
      'EndPos'        => nil, # int End position, possibly adjusted to match zoom boundaries
      'StartPos'      => nil, # int Start position, possibly adjusted to match zoom boundaries
    }
  end

  def to_s
    return "Chrom #{get_attr('Chrom')}: #{get_attr('StartPos')}-#{get_attr('EndPos')}, BucketSize=#{get_attr('BucketSize')}"
  end
end

end # module BaseSpace
end # module Bio

