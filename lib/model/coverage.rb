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

class Coverage
  attr_reader :swagger_types
  attr_accessor :chrom, :bucket_size, :mean_coverage, :end_pos, :start_pos

  def initialize
    @swagger_types = {
      :chrom          => 'str',
      :bucket_size    => 'int',
      :mean_coverage  => 'list<int>',
      :end_pos        => 'int',
      :start_pos      => 'int'
    }

    @chrom            = nil # str
    # Each returned number will represent coverage of this many bases.
    @bucket_size      = nil # int
    @mean_coverage    = nil # list<Str>
    # End position, possibly adjusted to match zoom boundaries
    @end_pos          = nil # int
    # Start position, possibly adjusted to match zoom boundaries
    @start_pos        = nil # int
  end

  def to_s
    return "Chr#{@chrom}: #{@start_pos}-#{@end_pos}: BucketSize=#{@bucket_size}"
  end

  def to_str
    return self.to_s
  end
end

end # module BaseSpace
end # module Bio

