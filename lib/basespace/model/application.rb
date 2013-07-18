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

# An App representation, which contains data such as name, homepage URI, a short
# description and the data the App was created.
class Application < Model

  # Create a new instance.
  def initialize
    @swagger_types = {
      'Id'                => 'str',
      'Href'              => 'str',
      'Name'              => 'str',
      'HomepageUri'       => 'str',
      'ShortDescription'  => 'str',
      'DateCreated'       => 'datetime',
    }
    @attributes = {
      'Id'                => nil,
      'Href'              => nil,
      'Name'              => nil,
      'HomepageUri'       => nil,
      'ShortDescription'  => nil,
      'DateCreated'       => nil,
    }
  end

end

end # module BaseSpace
end # module Bio

