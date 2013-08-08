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

# Creating an AppResult and Uploading Files
# https://github.com/basespace/basespace-ruby-sdk#creating-an-appresult-and-uploading-files

require 'bio-basespace-sdk'

include Bio::BaseSpace

# This script demonstrates how to create a new AppResults object, change its state
# and upload result files to it and download files from it.  

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
bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'], opts['access_token'])

### Creating an AppResult ###

#
# Request privileges
#

access_map = bs_api.get_verification_code('browse global')
link = access_map['verification_with_code_uri']
puts "Visit the URI within 15 seconds and grant access:"
puts link
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

#
# Get a project
#

# NOTE THAT YOUR PROJECT ID WILL MOST LIKELY BE DIFFERENT!
# YOU CAN GET IT VIA THE SDK OR FROM THE BASESPACE WEB INTERFACE!
# FOR EXAMPLE: my_projects.first.id
puts 'NOTE THAT YOU NEED TO UPDATE THE PROJECT ID IN THE EXAMPLE CODE TO MATCH A PROJECT OF YOURS!'
prj = bs_api.get_project_by_id('469469')

#
# List the current analyses for the project
#

statuses = ['Running']
app_res = prj.get_app_results(bs_api, {}, statuses)
puts "AppResult instances: #{app_res.join(', ')}"

#
# Request project creation privileges
#

access_map = bs_api.get_verification_code("create project #{prj.id}")
link = access_map['verification_with_code_uri']
puts "Visit the URI within 15 seconds and grant access:"
puts link
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

# NOTE THAT THE APP SESSION ID OF A RUNNING APP MUST BE PROVIDED!
app_result = prj.create_app_result(bs_api, "testing", "this is my results", bs_api.app_session_id)
puts "AppResult ID: #{app_result.id}"
puts "AppResult's AppSession: #{app_result.app_session}"

#
# Change the status of our `AppSession` and add a status-summary as follows:
#

app_result.app_session.set_status(bs_api, 'needsattention', "We worked hard, but encountered some trouble.")

# Updated status:
puts "AppResult's AppSession: #{app_result.app_session}"

# Set back to running:
app_result.app_session.set_status(bs_api, 'running', "Back on track")

### Uploading Files ###

#
# Attach a file to the `AppResult` object and upload it:
#

puts 'NOTE: THIS ASSUMES A FILE /tmp/testFile.txt IN YOUR FILESYSTEM!'
app_result.upload_file(bs_api, '/tmp/testFile.txt', 'BaseSpaceTestFile.txt', '/mydir/', 'text/plain')

# Let's see if our new file made it into the cloud:
app_result_files = app_result.get_files(bs_api)
puts "Files: #{app_result_files.join(', ')}"

#
# Download our newly uploaded file (will be saved as BaseSpaceTestFile.txt):

f = bs_api.get_file_by_id(app_result_files.last.id)
f.download_file(bs_api, '/tmp/')
puts 'NOTE: downloaded \'BaseSpaceTestFile.txt\' into the /tmp directory.'

