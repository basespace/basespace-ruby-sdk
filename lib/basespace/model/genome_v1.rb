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

class GenomeV1
  attr_reader :swagger_types
  attr_accessor :source, :species_name, :build, :id, :href, :display_name

  def initialize
    @swagger_types = {
      :source        => 'str',
      :species_name  => 'str',
      :build         => 'str',
      :id            => 'str',
      :href          => 'str',
      :display_name  => 'str'
    }

    @source          = nil # str
    @species_name    = nil # str
    @build           = nil # str
    @id              = nil # str
    @href            = nil # str
    @display_name    = nil # str
  end

  def to_s
    if @species_name
      return @species_name
    elsif @display_name
      return @display_name
    else
      return "Genome @ #{@href}"
    end
  end

  def to_str
    return self.inspect
  end
end

end # module BaseSpace
end # module Bio

