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
# https://github.com/basespace/basespace-ruby-sdk#application-triggering

require 'bio-basespace-sdk'

include Bio::BaseSpace

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

# Initialize a BaseSpace API object:
bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'])

# Using bs_api, we can request the AppSession object corresponding to the AppSession ID supplied
my_app_session = bs_api.get_app_session
puts my_app_session

# An app session contains a referral to one or more AppSessionLaunchObject instances, which reference the
# data module the user launched the App on. This can be a list of projects, samples, or a mixture of objects
puts "Type of data the app was triggered on can be seen in 'references':"
puts my_app_session.references.inspect  # `inspect` shows the object contents

#
# We can get a handle to the user who started the `AppSession` and further information on the `AppSessionLaunchObject`:
#

puts "App session created by user:"
puts my_app_session.user_created_by
puts

# Let's have a closer look at the AppSessionLaunchObject class instance:
my_reference = my_app_session.references.first

puts "href to the launch object:"
puts my_reference.href_content
puts
puts "Type of that object:"
puts my_reference.type
puts

#
# This section shows how one can easily obtain the so-called "scope string" and make the access request.
#
# More background reading on scope strings can be found in the BaseSpace developer documentation under
#
#   "BaseSpace Permissions"
#   https://developer.basespace.illumina.com/docs/content/documentation/authentication/using-scope
#

puts "Project object:"
my_reference_content =  my_reference.content
puts my_reference_content
puts
puts "Scope string for requesting write access to the reference object:"
puts my_reference_content.get_access_str('write')

#
# The following call requests write permissions:
#

access_map = bs_api.get_access(my_reference_content, 'write')
puts "Access map:"
puts access_map

#
# Confirm 'write' privilege request:
#

puts "Visit the URI within 15 seconds and grant access:"
verification_with_code_uri = access_map['verification_with_code_uri']
puts verification_with_code_uri

host = RbConfig::CONFIG['host_os']
case host
when /mswin|mingw|cygwin/
  system("start #{verification_with_code_uri}")
when /darwin/
  system("open #{verification_with_code_uri}")
when /linux/
  system("xdg-open #{verification_with_code_uri}")
end
sleep(15)

code = access_map['device_code']
bs_api.update_privileges(code)

