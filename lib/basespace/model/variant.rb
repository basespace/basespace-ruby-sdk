# Copyright 2013 Toshiaki Katayama, Joachim Baran
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

# Variant model.
class Variant < Model

  # Create a new Variant instance.
  def initialize
    @swagger_types = {
      'CHROM'         => 'str',                 
      'ALT'           => 'str',
      'ID'            => 'list<Str>',
      'SampleFormat'  => 'dict',
      'FILTER'        => 'str',
      'INFO'          => 'dict',
      'POS'           => 'int',
      'QUAL'          => 'int',
      'REF'           => 'str',
    }
    @attributes = {
      'CHROM'         => nil,
      'ALT'           => nil,
      'ID'            => nil,
      'SampleFormat'  => nil,
      'FILTER'        => nil,
      'INFO'          => nil,
      'POS'           => nil,
      'QUAL'          => nil,
      'REF'           => nil,
    }
  end

  # Return the genomic coordinate and ID of the variant as string.
  def to_s
    return "Variant - #{get_attr('CHROM')}: #{get_attr('POS')} id=#{get_attr('Id')}"
  end

end

end # module BaseSpace
end # module Bio

