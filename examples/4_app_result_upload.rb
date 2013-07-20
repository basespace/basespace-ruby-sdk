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

# Creating an AppResult and uploading files
#   https://developer.basespace.illumina.com/docs/content/documentation/sdk-samples/python-sdk-overview#Creating_an_AppResult_and_uploading_files

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

# First, create a client for making calls for this user session.
bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'], opts['access_token'])

# Now we'll do some work of our own. First get a project to work on.
# We need write permission for the project we are working on,
# meaning we will need get a new token and instantiate a new BaseSpaceAPI.
prj = bs_api.get_project_by_id('89')  # [TODO] Original ID '89' was not accessible. Writable project is needed.

# Assuming we have write access to the project
# we list the current App Results for the project.
statuses = ['Running']
app_res = prj.get_app_results(bs_api, {}, statuses)  # [TODO] should introduce hash options / keyword arguments (in Ruby 2.0)
puts "The current running AppResults are #{app_res}"
puts

#
# Retrieving results and setting status
#

# To create an appResults for a project, simply give the name and description.
app_results = prj.create_app_result(bs_api, "testing", "this is my results")
puts "Some info about our new app results"
puts app_results
puts app_results.id
puts
puts "The app results also comes with a reference to our AppSession"
my_app_session = app_results.app_session
puts my_app_session
puts

# We can change the status of our AppSession and add a status-summary as follows.
my_app_session.set_status(bs_api, 'needsattention', "We worked hard, but encountered some trouble.")
puts "After a change of status of the app sessions we get #{my_app_session}"
puts
# We set our appSession back to running so we can do some more work.
my_app_session.set_status(bs_api, 'running', "Back on track")


# Let's list all AppResults again and see if our new object shows up.
app_res = prj.get_app_results(bs_api, {}, ['Running'])
puts "The updated app results are #{app_res}"
app_result2 = bs_api.get_app_result_by_id(app_results.id)
puts app_result2
puts

# Now we will make another AppResult and try to upload a file to it
app_results2 = prj.create_app_result(bs_api, "My second AppResult", "This one I will upload to")
app_results2.upload_file(bs_api, '/home/mkallberg/Desktop/testFile2.txt', 'BaseSpaceTestFile.txt', '/mydir/', 'text/plain')
puts "My AppResult number 2 #{app_results2}"
puts

# Let's see if our new file made it.
app_result_files = app_results2.get_files(bs_api)
puts "These are the files in the appResult"
puts app_result_files
f = app_result_files.last

# We can even download our newly uploaded file.
f = bs_api.get_file_by_id(f.id)
f.download_file(bs_api, '/home/mkallberg/Desktop/')

