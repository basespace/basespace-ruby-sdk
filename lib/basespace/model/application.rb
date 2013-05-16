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

class Application
  attr_reader :swagger_types
  attr_accessor :id, :href, :name, :homepage_uri, :short_description, :date_created
  
  def initialize
    @swagger_types = {
      :id                 => 'str',
      :href               => 'str',
      :name               => 'str',
      :homepage_uri       => 'str',
      :short_description  => 'str',
      :date_created       => 'datetime'
    }

    @id                   = nil
    @href                 = nil
    @name                 = nil
    @homepage_uri         = nil
    @short_description    = nil
    @date_created         = nil
  end
end

end # module BaseSpace
end # module Bio

