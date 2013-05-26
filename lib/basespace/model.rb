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

class Model
  attr_reader :swagger_types, :attributes

  def initialize
    @swagger_types = {}
    @attributes = {}
  end

  def method_missing(method, *args, &block)
    attr_name = method.to_s.downcase.gsub('_', '')
    attr_value = false
    self.attributes.each do |key, value|
      if key.downcase == attr_name
        attr_value = value  # can be an object or nil
      end
    end
    if attr_value == false
      super
    else
      return attr_value
    end
  end

  def set_attr(key, value)
    @attributes[key] = value
    return @attributes
  end

  def get_attr(key)
    return @attributes[key]
  end

  def to_str
    return self.inspect
  end
end

end # module BaseSpace
end # module Bio
