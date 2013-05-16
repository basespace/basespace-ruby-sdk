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

class Product
  attr_reader :swagger_types
  attr_accessor :id, :name, :price, :quantity, :persistence_status, :tags

  def initialize
    @swagger_types = {
      :id                  => 'str',
      :name                => 'str',
      :price               => 'str',
      :quantity            => 'str',
      :persistence_status  => 'str', # NOPERSISTENCE, ACTIVE, EXPIRED
      :tags                => 'list<str>',
    }
  end

  def to_s
    return @name.to_s
  end

  def to_str
    return self.inspect
  end
end

end # module BaseSpace
end # module Bio
