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

require 'basespace/model'

module Bio
module BaseSpace

class PurchasedProduct < Model
  def initialize
    @swagger_types = {
      'PurchaseId'         => 'str',
      'DatePurchased'      => 'datetime',
      'Id'                 => 'str',
      'Name'               => 'str',
      'Price'              => 'str',
      'Quantity'           => 'str',
      'PersistenceStatus'  => 'str',
      'Tags'               => 'list<str>',  # only if provided as a query parameter
      'ProductIds'         => 'list<str>',  # only if provided as a query parameter
    }
    @attributes = {
      'PurchaseId'         => nil,
      'DatePurchased'      => nil,
      'Id'                 => nil,
      'Name'               => nil,
      'Price'              => nil,
      'Quantity'           => nil,
      'PersistenceStatus'  => nil,
      'Tags'               => nil,
      'ProductIds'         => nil,
    }
  end

  def to_s
    return get_attr('Name').to_s
  end
end

end # module BaseSpace
end # module Bio
