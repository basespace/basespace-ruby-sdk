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

# Application triggering
#   https://developer.basespace.illumina.com/docs/content/documentation/sdk-samples/python-sdk-overview#Application_triggering

require 'basespace'

include Bio::BaseSpace

# This script demonstrates how to retrieve the AppSession object produced 
# when a user initiates an app. Further it's demonstrated how to automatically
# generate the scope strings to request access to the data object (a project or a sample)
# that the app was triggered to analyze.
# 
# NOTE: You will need to fill in client values for your app below

# Initialize an authentication object using the key and secret from your app.
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

# First we will initialize a BaseSpace API object using our app information and the appSessionId.
bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'])

# Using the bmy_app_session.spaceApi we can request the appSession object corresponding to the AppSession id supplied.
my_app_session = bs_api.get_app_session
puts my_app_session

# An app session contains a referal to one or more appLaunchObjects which reference the data module
# the user launched the app on. This can be a list of projects, samples, or a mixture of objects.
puts "Type of data the app was triggered on can be seen in 'references'"
puts my_app_session.references.inspect   # same as my_app_session.get_attr('References') inspect is used to put surrounding [] 
puts

# We can also get a handle to the user who started the AppSession.
puts "We can get a handle for the user who triggered the app"
puts my_app_session.user_created_by      # same as my_app_session.get_attr('UserCreatedBy')
puts

# Let's have a closer look at the appSessionLaunchObject.
my_reference = my_app_session.references.first

puts "We can get out information such as the href to the launch object:"
puts my_reference.href_content           # same as my_reference.get_attr('HrefContent')
puts
puts "and the specific type of that object:"
puts my_reference.type                   # same as my_reference.get_attr('Type')
puts

# Now we will want to ask for more permission for the specific reference object.
my_reference_content = my_reference.content

puts "We can get out the specific project objects by using 'content':" 
puts my_reference_content
puts

puts "The scope string for requesting write access to the reference object is:"
puts my_reference_content.get_access_str('write')
puts

# We can easily request write access to the reference object, so that our App can start contributing analysis.
# By default, we ask for write permission and authentication for a device.
access_map = bs_api.get_access(my_reference_content, 'write')
# We may limit our request to read access only if that's all that is needed
read_access_map  = bs_api.get_access(my_reference_content, 'read')

puts "We get the following access map for the write request"
puts access_map
puts

# NOTE You'll need to use a writable project for the following code.
# It will fail if the session is read only (e.g., demo projects).

## PAUSE HERE
# Have the user visit the verification uri to grant us access.
puts "Please visit the following URL within 15 seconds and grant access"
puts access_map['verification_with_code_uri']

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
# BaseSpace exception: authorization_pending - User has not yet approved the access request (RuntimeError).
sleep(15)
## PAUSE HERE

# Once the user has granted us the access to the object we requested we can get
# the basespace access token and start browsing simply by calling updatePriviliges
# on the BaseSpaceAPI instance.
code = access_map['device_code']
bs_api.update_privileges(code)
puts "The BaseSpaceAPI instance was update with write privileges"
puts bs_api
puts

# for more details on access-requests and authentication and an example of the web-based case
# see example 1_authentication.rb







