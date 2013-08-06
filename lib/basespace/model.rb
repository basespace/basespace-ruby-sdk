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

module Bio
module BaseSpace

# Base class for all BaseSpace Ruby SDK model classes. Implements a
# basic key/value store and provides convenience methods for accessing
# the key/value store using `method_missing` magic.
#
# Keys in this model are referred to as "attribute names", whereas
# values are called "attributes".
class Model
  attr_reader :swagger_types, :attributes

  # Create a new (empty) model.
  def initialize
    @swagger_types = {}
    @attributes = {}
  end

  # If a method was called on the object for which no implementations is
  # provided, then execute this method and try to return the attribute
  # value whose attribute key matches the method call's name.
  #
  # +method+:: Method call for which no implementation could be found.
  # +args+:: Arguments that were provided to the method call.
  # +block+:: If not nil, code block that follows the method call.
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

  # Sets the value of a named attribute. Overrides the value of
  # a previous assignment.
  #
  # +key+:: Attribute name whose value should be set.
  # +value+:: Value that should be assigned.
  def set_attr(key, value)
    @attributes[key] = value
    return @attributes
  end

  # Returns the value, if any, of the given attribute name.
  #
  # +key+:: Attribute name whose value should be returned.
  def get_attr(key)
    return @attributes[key]
  end

  # Returns a string representation of the model.
  def to_s
    return self.inspect
  end
end

end # module BaseSpace
end # module Bio
