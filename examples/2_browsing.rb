#!/usr/bin/env ruby

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

# Browsing data with global browse access
#   https://developer.basespace.illumina.com/docs/content/documentation/sdk-samples/python-sdk-overview#Browsing_data_with_global_browse_access

require 'basespace'

include Bio::BaseSpace

# This script demonstrates basic browsing of BaseSpace objects once an access-token
# for global browsing has been obtained. 

opts = {
  # FILL IN WITH YOUR APP VALUES HERE!
  'client_id'       => '<your client key>',
  'client_secret'   => '<your client secret>',
  'access_token'    => '<your access token>',
  'app_session_id'  => '<app session id>',
  'basespace_url'   => 'https://api.basespace.illumina.com/',
  'api_version'     => 'v1pre3',
}

# test if client variables have been set
unless opts.select{|k,v| v[/^<.*>$/]}.empty?
  opts = Bio::BaseSpace.load_credentials
  exit 1 unless opts
end

# First, create a client for making calls for this user session 
my_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'], opts['access_token'])

# Now let's grab the genome with id=4
my_genome = my_api.get_genome_by_id('4')
puts "The Genome is #{my_genome}"
puts "We can get more information from the genome object"
puts "Id: #{my_genome.id}"
puts "Href: #{my_genome.href}"
puts "DisplayName: #{my_genome.display_name}"
puts

# Get a list of all genomes
all_genomes  = my_api.get_available_genomes
puts "Genomes: #{all_genomes}"
puts

# Let's have a look at the current user
user = my_api.get_user_by_id('current')
puts "The current user is #{user}"
puts

# Now list the projects for this user
my_projects = my_api.get_project_by_user('current')
puts "The projects for this user are #{my_projects}"
puts

# We can also achieve this by making a call using the 'user instance'
my_projects2 = user.get_projects(my_api)
puts "Projects retrieved from the user instance #{my_projects2}"
puts

# List the runs available for the current user
runs = user.get_runs(my_api)
puts "The runs for this user are #{runs}"
puts

=begin [TODO] commented out as this example is same as the above (bug in Python version?)
# In the same manner we can get a list of accessible user runs
runs = user.get_runs(my_api)
print "Runs retrieved from user instance #{runs}"
puts
=end
