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

# BaseSpace Authentication
# https://github.com/basespace/basespace-ruby-sdk#basespace-authentication

require 'bio-basespace-sdk'

include Bio::BaseSpace

opts = {
  # FILL IN WITH YOUR APP VALUES HERE!
  'client_id'       => '<your client key>',
  'client_secret'   => '<your client secret>',
  'access_token'    => '<your access token>',
  'app_session_id'  => '<app session id>',
  'basespace_url'   => 'https://api.basespace.illumina.com/',
  'api_version'     => 'v1pre3',
}

# Test if client variables have been set.
unless opts.select{|k,v| v[/^<.*>$/]}.empty?
  opts = Bio::BaseSpace.load_credentials
  exit 1 unless opts
end

# Initialize a BaseSpace API object:
bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'])

#
# Get the verification code and uri for scope 'browse global':
#

access_map = bs_api.get_verification_code('browse global')
puts "URI for user to visit and grant access:"
puts access_map['verification_with_code_uri']

#
# Grant access privileges:
#

link = access_map['verification_with_code_uri']
host = RbConfig::CONFIG['host_os']
case host
when /mswin|mingw|cygwin/
  system("start #{link}")
when /darwin/
  system("open #{link}")
when /linux/
  system("xdg-open #{link}")
end
sleep(15)

code = access_map['device_code']
bs_api.update_privileges(code)

puts "Access-token: #{bs_api.get_access_token}"

