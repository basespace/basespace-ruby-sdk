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

# Browsing Data
# https://github.com/basespace/basespace-ruby-sdk#browsing-data

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
bs_api = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'], opts['access_token'])

#
# Retrieve a genome object:
#

my_genome = bs_api.get_genome_by_id('4')
puts "Genome: #{my_genome}"
puts "Id: #{my_genome.id}"
puts "Href: #{my_genome.href}"
puts "DisplayName: #{my_genome.display_name}"

#
# Get a list of all available genomes:
#

all_genomes  = bs_api.get_available_genomes
puts "Genomes: #{all_genomes.map { |g| g.to_s }.join(', ')}"

#
# Retrieve the `User` object for the current user and list all projects for this user:
#

user = bs_api.get_user_by_id('current')
puts "User -- #{user}"

my_projects = bs_api.get_project_by_user('current')
puts "Projects: #{my_projects.map { |p| p.to_s }.join(', ')}"

#
# We can also achieve this by making a call to the `User` instance:
#

my_projects = user.get_projects(bs_api)
puts "Projects: #{my_projects.map { |p| p.to_s }.join(', ')}"

#
# List all runs for a user:
#

runs = user.get_runs(bs_api)
puts "Runs: #{runs.map { |r| r.to_s }.join(', ')}"

