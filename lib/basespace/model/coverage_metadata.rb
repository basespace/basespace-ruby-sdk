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

class CoverageMetadata < Model
  def initialize
    @swagger_types = {
      'MaxCoverage'          => 'int',
      'CoverageGranularity'  => 'int',
    }
    @attributes = {
      'MaxCoverage'          => nil, # int Maximum coverage value of any base, on a per-base level, for the entire chromosome. Useful for scaling
      'CoverageGranularity'  => nil, # int Supported granularity of queries
    }
  end

  def to_s
    return "CoverageMeta: max=#{get_attr('MaxCoverage')} gran=#{get_attr('CoverageGranularity')}"
  end
end

end # module BaseSpace
end # module Bio

