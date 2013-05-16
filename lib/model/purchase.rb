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

require 'api/basespace_error'

module Bio
module BaseSpace

# Represents a BaseSpace Purchase object.
class Purchase
  attr_reader :swagger_types
  attr_accessor :id, :status, :refund_status, :date_created, :date_updated, :invoice_number, :amount, :amount_of_tax, :amount_total, :products, :purchase_type, :app_session, :user, :application, :href_purchase_dialog, :refund_secret, :exception_message, :exception_stack_trace, :date_refunded, :user_refunded_by, :refund_comment

  def initialize
    @swagger_types = {
      :id                     => 'str',
      :status                 => 'str',       # PENDING, CANCELLED, ERRORED, COMPLETED
      :refund_status          => 'str',       # NOTREFUNDED, REFUNDED
      :date_created           => 'datetime',
      :date_updated           => 'datetime',
      :invoice_number         => 'str',
      :amount                 => 'str',
      :amount_of_tax          => 'str',
      :amount_total           => 'str',
      :products               => 'list<Product>',
      :purchase_type          => 'str',
      :app_session            => 'AppSessionCompact',
      :user                   => 'UserCompact',
      :application            => 'ApplicationCompact',
      :href_purchase_dialog   => 'str',       # new purchases only
      :refund_secret          => 'str',       # new purchases only
      :exception_message      => 'str',       # errors only
      :exception_stack_trace  => 'str',       # errors only
      :date_refunded          => 'datetime',  # refunds only
      :user_refunded_by       => 'str',       # refunds only
      :refund_comment         => 'str',       # refunds only
    }
  end
  
  def to_s
    return @id.to_s
  end

  def to_str
    return self.inspect
  end
  
  # Is called to test if the Purchase instance has been initialized.
  # Throws:
  #     ModelNotInitializedError - Indicates the object has not been populated yet.
  def is_init
    raise ModelNotInitializedError.new('The project model has not been initialized yet') unless @id
  end
end

end # module BaseSpace
end # module Bio

