#!/usr/bin/env ruby

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

# Purchasing
# --- Sorry, we have not documented this yet. ---

require 'bio-basespace-sdk'

include Bio::BaseSpace

opts = {
  # FILL IN WITH YOUR APP VALUES HERE!
  'client_id'            => '<your client key>',     # from dev portal app Credentials tab
  'client_secret'        => '<your client secret>',  # from dev portal app Credentials tab
  'access_token'         => '<your access token>',   # from oauth2
  'app_session_id'       => '<app session id>',      # from launching an app
  'basespace_url'        => 'https://api.basespace.illumina.com/',
  'api_version'          => 'v1pre3',
  'basespace_store_url'  => 'https://hoth-store.basespace.illumina.com/',
  'product_id'           => '',                      # from dev portal Pricing tab
}

# Test if client variables have been set.
unless opts.select{|k,v| v[/^<.*>$/]}.empty?
  opts = Bio::BaseSpace.load_credentials
  exit 1 unless opts
end

unless opts['client_id'] or opts['product_id']
  raise "Please fill in client values (in the script) before running the script"
end

# Initialize a BaseSpace API object:
bill_api = BillingAPI.new(opts['basespace_store_url'], opts['api_version'], opts['app_session_id'], opts['access_token'])

# Create a non-consumable purchase.
#purch = bill_api.create_purchase([{'id':product_id,'quantity':4 }])

# Create a consumable purchase, and associated it with an AppSession
# also add tags to provide (fake) details about the purchase.
puts "Creating purchase"
# purch = billAPI.createPurchase({'id':product_id,'quantity':4, 'tags':["test","test_tag"] }, AppSessionId)
products = {
  'id'        => opts['product_id'],
  'quantity'  => 4,
  'tags'      => ["test", "test_tag"],
}
purch = bill_api.create_purchase(products, opts['app_session_id'])

# Record the purchase Id and RefundSecret for refunding later.
purchase_id    = purch.id
refund_secret  = purch.refund_secret

puts "Now complete the purchase in your web browser"
puts "CLOSE the browser window/tab after you click 'Purchase' (and don't proceed into the app)"
time.sleep(3)
## PAUSE HERE
link = purch.href_purchase_dialog
puts "Opening: #{link}"
host = RbConfig::CONFIG['host_os']
case host
when /mswin|mingw|cygwin/
  system("start #{link}")
when /darwin/
  system("open #{link}")
when /linux/
  system("xdg-open #{link}")
end
puts "Waiting 30 seconds..."
time.sleep(30)
## PAUSE HERE

puts "Confirm the purchase"
post_purch = bill_api.get_purchase_by_id(purchase_id)
puts "The status of the purchase is now: " + post_purch.status
puts

puts "Refunding the Purchase"
puts
# NOTE We must use the same access token that was provided used for the purchase.
refunded_purchase = bill_api.refund_purchase(purchase_id, refund_secret, 'the product did not function well as a frisbee')

puts "Getting all purchases for the current user with the tags we used for the purchase above"
puts
#purch_prods = bill_api.get_user_products
purch_prods = bill_api.get_user_products('current', {'Tags' => 'test,test_tag'})
if purch_prods.nil? or purch_prods.empty?
  puts "Hmmm, didn't find any purchases with these tags. Did everything go OK above?"
else
  puts "For the first of these purchases:"
  puts "Purchase Name: #{purch_prods[0].name}"
  puts "Purchase Price: #{purch_prods[0].price}"
  puts "Purchase Quantity: #{purch_prods[0].quantity}"
  puts "Tags: #{purch_prods[0].tags}"
  # Get the refund status of the purchase
  puts "Getting the (refunded) Purchase we just made"
  get_purch = bill_api.get_purchase_by_id(purch_prods[0].purchase_id)
  puts "Refund Status: #{get_purch.refund_status}"
end


