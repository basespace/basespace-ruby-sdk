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

require 'basespace/api/basespace_error'
require 'basespace/model'

module Bio
module BaseSpace

# Represents a BaseSpace Purchase object.
class Purchase < Model
  def initialize
    @swagger_types = {
      'Id'                   => 'str',
      'Status'               => 'str',       # PENDING, CANCELLED, ERRORED, COMPLETED
      'RefundStatus'         => 'str',       # NOTREFUNDED, REFUNDED
      'DateCreated'          => 'datetime',
      'DateUpdated'          => 'datetime',
      'InvoiceNumber'        => 'str',
      'Amount'               => 'str',
      'AmountOfTax'          => 'str',
      'AmountTotal'          => 'str',
      'Products'             => 'list<Product>',
      'PurchaseType'         => 'str',
      'AppSession'           => 'AppSessionCompact',
      'User'                 => 'UserCompact',
      'Application'          => 'ApplicationCompact',
      'HrefPurchaseDialog'   => 'str',       # new purchases only
      'RefundSecret'         => 'str',       # new purchases only
      'ExceptionMessage'     => 'str',       # errors only
      'ExceptionStackTrace'  => 'str',       # errors only
      'DateRefunded'         => 'datetime',  # refunds only
      'UserRefundedBy'       => 'str',       # refunds only
      'RefundComment'        => 'str',       # refunds only
    }
    @attributes = {
      'Id'                   => nil,
      'Status'               => nil,
      'RefundStatus'         => nil,
      'DateCreated'          => nil,
      'DateUpdated'          => nil,
      'InvoiceNumber'        => nil,
      'Amount'               => nil,
      'AmountOfTax'          => nil,
      'AmountTotal'          => nil,
      'Products'             => nil,
      'PurchaseType'         => nil,
      'AppSession'           => nil,
      'User'                 => nil,
      'Application'          => nil,
      'HrefPurchaseDialog'   => nil,
      'RefundSecret'         => nil,
      'ExceptionMessage'     => nil,
      'ExceptionStackTrace'  => nil,
      'DateRefunded'         => nil,
      'UserRefundedBy'       => nil,
      'RefundComment'        => nil,
    }
  end
  
  def to_s
    return @id.to_s
  end

  # Is called to test if the Purchase instance has been initialized.
  # Throws:
  #     ModelNotInitializedError - Indicates the object has not been populated yet.
  def is_init
    raise ModelNotInitializedError.new('The project model has not been initialized yet') unless get_attr('Id')
  end
end

end # module BaseSpace
end # module Bio

