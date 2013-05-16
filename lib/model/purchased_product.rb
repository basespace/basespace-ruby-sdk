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

class PurchasedProduct
  attr_reader :swagger_types
  attr_accessor :purchase_id, :date_purchased, :id, :name, :price, :quantity, :persistence_status, :tags, :product_ids

  def initialize
    @swagger_types = {
      :purchase_id         => 'str',
      :date_purchased      => 'datetime',
      :id                  => 'str',
      :name                => 'str',
      :price               => 'str',
      :quantity            => 'str',
      :persistence_status  => 'str',
      :tags                => 'list<str>',  # only if provided as a query parameter
      :product_ids         => 'list<str>',  # only if provided as a query parameter
    }
  end

  def to_s
    return @name.to_s
  end

  def to_str
    return self.to_s
  end
end

end # module BaseSpace
end # module Bio
