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

require 'api/base_api'
require 'api/basespace_error'
require 'model/query_parameters_purchased_product'

module Bio
module BaseSpace

# The API class used for all communication with the BaseSpace Billng server
class BillingAPI < BaseAPI
  def initialize(api_server, version, app_session_id = nil, access_token = nil)
    end_with_slash = %r(/$)
    unless api_server[end_with_slash]
      api_server += '/'
    end
    
    @app_session_id  = app_session_id
    @api_server      = api_server + version
    @version         = version

    super(access_token)
  end

  # Creates a purchase with the specified products
  # 
  # :param products: List of dicts to purchase, each of which has a product 'id'
  #     and 'quantity' to purchase
  def create_purchase(products, app_session_id = nil)
    my_model       = 'PurchaseResponse'
    resource_path  = '/purchases/'
    resource_path  = resource_path.sub('{format}', 'json')
    method         = 'POST'
    query_params   = {}
    header_params  = {}
    post_data      = {}
    # 'Products' is list of dicts with 'id', 'quantity', and optnl 'tags[]'
    post_data['Products']  = products
    if app_session_id
      post_data['AppSessionId'] = app_session_id
    end
    verbose        = false
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end
          
  # Request a purchase object by Id
  # 
  # :param id: The Id of the purchase
  def get_purchase_by_id(id)
    my_model       = 'PurchaseResponse'
    resource_path  = '/purchases/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    return single_request(my_model, resource_path, method, query_params, header_params)
  end

  # Returns the Products for the current user
  # :param id: The id of the user, optional
  # :param qps: Query parameters, a dictionary for filtering by 'Tags' and/or 'ProductIds', optional
  def get_user_products(id = 'current', qps = {})
    query_pars     = QueryParametersPurchasedProduct.new(qps)
    my_model       = 'PurchasedProduct'
    resource_path  = '/users/{Id}/products'
    resource_path  = resource_path.sub('{Id}', id.to_s)
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    return self.__listRequest__(my_model, resource_path, method, query_params, header_params)
  end

  # Creates a purchase with the specified products
  # 
  # :param purchase_id: The Id of the purchase
  # :param refund_secret: The RefundSecret that was provided in the Response from createPurchase()
  # :param comment: An optional comment about the refund
  def refund_purchase(purchase_id, refund_secret, comment = nil)
    my_model       = 'RefundPurchaseResponse'
    resource_path  = '/purchases/{id}/refund'
    resource_path  = resource_path.sub('{id}', purchase_id)
    method         = 'POST'
    query_params   = {}
    header_params  = {}
    post_data      = {}
    post_data['RefundSecret']  = refund_secret
    if comment
      post_data['Comment']     = comment
    end
    verbose        = 0
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end
end

end # module BaseSpace
end # module Bio
