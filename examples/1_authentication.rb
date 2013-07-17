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

# Requesting an access-token for data browsing
#   https://developer.basespace.illumina.com/docs/content/documentation/sdk-samples/python-sdk-overview#Requesting_an_access-token_for_data_browsing

require 'basespace'

include Bio::BaseSpace

# Demonstrates the basic BaseSpace authentication process The work-flow is as follows: 
# scope-request -> user grants access -> browsing data. The scenario is demonstrated both for device and web-based apps.
# 
# Further we demonstrate how a BaseSpaceAPI instance may be preserved across multiple
# http-request for the same app session using Python's pickle module.
# 
# NOTE You will need to fill client values for your app below!

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

bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'])

# First, get the verification code and uri for scope 'browse global'.
device_info = bs_api.get_verification_code('browse global')

## PAUSE HERE
# Have the user visit the verification uri to grant us access.
puts "Please visit the following URL within 15 seconds and grant access"
puts device_info['verification_with_code_uri']

link = device_info['verification_with_code_uri']
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
## PAUSE HERE

# Once the user has granted us access to objects we requested, we can get
# the basespace access token and start browsing simply by calling updatePriviliges
# on the baseSpaceApi instance.
code = device_info['device_code']
bs_api.update_privileges(code)

# As a reference the provided access-token can be obtained from the BaseSpaceAPI object.
puts "My Access-token: #{bs_api.get_access_token}"
puts

# Let's try and grab all available genomes with our new api! 
all_genomes  = bs_api.get_available_genomes
puts "Genomes: #{all_genomes}"
puts

# If at a later stage we wish to initialize a BaseSpaceAPI object when we already have
# an access-token from a previous sessions, this may simply be done by initializing the BaseSpaceAPI
# object using the key-word AccessToken.
my_token = bs_api.get_access_token
bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'], my_token)
puts "A BaseSpaceAPI instance initialized with an access-token:"
puts bs_api
puts

#################### Web-based verification #################################
# The scenario where the authentication is done through a web-browser.

bs_api_web = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'])
user_url= bs_api_web.get_web_verification_code('browse global', 'http://localhost', 'myState')

puts "Have the user visit:"
puts user_url
puts

link = user_url
host = RbConfig::CONFIG['host_os']
case host
when /mswin|mingw|cygwin/
  system("start #{link}")
when /darwin/
  system("open #{link}")
when /linux/
  system("xdg-open #{link}")
end

# Once the grant has been given you will be redirected to a url looking something like this
# http://localhost/?code=<MY DEVICE CODE FROM REDICRECT>&state=myState&action=oauthv2authorization
# By getting the code parameter from the above http request we can now get our access-token.

my_code = '<MY DEVICE CODE FROM REDICRECT>'
#bs_api_web.update_privileges(my_code)

user = bs_api.get_user_by_id('current')
puts "Get current user"
puts user
puts bs_api
puts

#### Carry on with the work...

# Now we wish to store the API object for the next time we get a request in this session
# make a file to store the BaseSpaceAPI instance in. For easy identification we will name
# this by any id that may be used for identifying the session again.
my_session_id = bs_api.app_session_id + '.marshal'
File.open(my_session_id, 'w') do |f|
  Marshal.dump(bs_api, f)
end

# Imagine the current request is done, we will simulate this by deleting the api instance.
bs_api = nil
puts "Try printing the removed API, we get: '#{bs_api}' (<-- should be empty)"
puts

# Next request in the session with id = id123 comes in.
# We will check if there is already a BaseSpaceAPI stored for the session.
if File.exists?(my_session_id)
  File.open(my_session_id) do |f|
    bs_api = Marshal.load(f)
  end
  puts
  puts "We got the API back!"
  puts bs_api
else
  puts "Looks like we haven't stored anything for this session yet"
  # create a BaseSpaceAPI for the first time
end

