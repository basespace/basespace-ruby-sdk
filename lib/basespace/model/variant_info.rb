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

class VariantInfo
  attr_reader :swagger_types
  attr_accessor :cigar, :idrep, :refrep, :ru, :vartype_del, :vartype_ins, :vartype_snv

  def initialize
    @swagger_types = {
      :cigar        => 'list<Str>',
      :idrep        => 'list<Str>',                 
      :refrep       => 'list<Str>',
      :ru           => 'list<Str>',
      :vartype_del  => 'list<Str>',
      :vartype_ins  => 'list<Str>',
      :vartype_snv  => 'list<Str>',
    }

    @cigar          = nil
    @idrep          = nil
    @refrep         = nil
    @ru             = nil
    @vartype_del    = nil
    @vartype_ins    = nil
    @vartype_snv    = nil
  end
end

end # module BaseSpace
end # module Bio
 
