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

class CoverageMetadata
  attr_reader :swagger_types
  attr_accessor :max_coverage, :coverage_granularity

  def initialize
    @swagger_types = {
      :max_coverage          => 'int',
      :coverage_granularity  => 'int'
    }

    # Maximum coverage value of any base, on a per-base level, for the entire chromosome. Useful for scaling
    @max_coverage            = nil # int
    # Supported granularity of queries
    @coverage_granularity    = nil # int
  end

  def to_s
    return "CoverageMeta: max=#{@max_coverage} gran=#{@coverage_granularity}"
  end

  def to_str
    self.to_s
  end
end

end # module BaseSpace
end # module Bio

