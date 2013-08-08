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

# Accessing and Querying Files
# https://github.com/basespace/basespace-ruby-sdk#accessing-and-querying-files

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

### Accessing Files ###

#
# Get a project that we can work with:
#

user = bs_api.get_user_by_id('current')
my_projects = bs_api.get_project_by_user('current')

#
# List all the analyses and samples for these projects:
#

# Define 'samples' variable here, so that it can be reused further into the example again:
samples = nil
my_projects.each do |single_project|
  puts "Project: #{single_project}"

  app_results = single_project.get_app_results(bs_api)
  puts "  AppResult instances: #{app_results.join(', ')}"

  samples = single_project.get_samples(bs_api)
  puts "  Sample instances: #{samples.join(', ')}"
end

#
# Look at the files belonging to the sample from the last project in the loop above:
#

samples.each do |sample|
  puts "Sample: #{sample}"
  files = sample.get_files(bs_api)
  puts files.map { |f| "  #{f}" }
end

### Querying BAM and VCF Files ###

#
# Request privileges
#

# NOTE THAT YOUR PROJECT ID (469469 here) WILL MOST LIKELY BE DIFFERENT!
puts 'NOTE: CHANGE THE PROJECT ID IN THE EXAMPLE TO MATCH A PROJECT OF YOURS!'
access_map = bs_api.get_verification_code('read project 469469')
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
# Get the coverage for an interval + accompanying meta-data
#

# NOTE THAT YOUR FILE ID (here 7823816) WILL MOST LIKELY BE DIFFERENT!
# A FILE ID CAN BE OBTAINED, E.G., USING: samples.first.get_files(bs_api).first.id
puts 'NOTE: CHANGE THE FILE ID IN THE EXAMPLE TO MATCH A BAM FILE OF YOURS!'
my_bam = bs_api.get_file_by_id('7823816')
puts "BAM: #{my_bam}"
cov = my_bam.get_interval_coverage(bs_api, 'chr1', '50000', '60000')
puts "  #{cov.to_s}"
cov_meta = my_bam.get_coverage_meta(bs_api, 'chr1')
puts "  #{cov_meta.to_s}"

# For VCF-files we can filter variant calls based on chromosome and location as well:
puts 'NOTE: CHANGE THE FILE ID IN THE EXAMPLE TO MATCH A VCF FILE OF YOURS!'
my_vcf = bs_api.get_file_by_id('7823817')
var_meta = my_vcf.get_variant_meta(bs_api)
puts var_meta
var = my_vcf.filter_variant(bs_api, '1', '20000', '30000') # no value. need verification
puts "  #{var.join(', ')}"

