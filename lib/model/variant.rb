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

class Variant
  attr_reader :swagger_types
  attr_accessor :chrom, :alt, :id, :sample_format, :filter, :info, :pos, :qual, :ref

  def initialize
    @swagger_types = {
      :chrom          => 'str',                 
      :alt            => 'str',
      :id             => 'list<Str>',
      :sample_format  => 'dict',
      :filter         => 'str',
      :info           => 'dict',
      :pos            => 'int',
      :qual           => 'int',
      :ref            => 'str'
    }

    @chrom            = nil
    @alt              = nil
    @id               = nil
    @sample_format    = nil 
    @filter           = nil
    @info             = nil
    @pos              = nil
    @qual             = nil
    @ref              = nil
  end

  def to_s
    return "Variant - #{@chrom}: #{@pos} id=#{@id}"
  end

  def to_str
    return self.inspect
  end
end

end # module BaseSpace
end # module Bio

