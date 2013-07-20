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

# Accessing file-trees and querying BAM or VCF files
#   https://developer.basespace.illumina.com/docs/content/documentation/sdk-samples/python-sdk-overview#Accessing_file-trees_and_querying_BAM_or_VCF_files

require 'bio-basespace-sdk'

include Bio::BaseSpace

# This script demonstrates how to access Samples and AppResults from a projects and
# how to work with the available file data for such instances. 

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
my_api       = BaseSpaceAPI.new(opts['client_id'], opts['client_secret'], opts['basespace_url'], opts['api_version'], opts['app_session_id'], opts['access_token'])
user         = my_api.get_user_by_id('current')
my_projects  = my_api.get_project_by_user('current')

app_results  = nil
samples      = nil

# Let's list all the AppResults and samples for these projects.
my_projects.each do |single_project|
  puts "# Project: #{single_project}"

  app_results = single_project.get_app_results(my_api)
  puts "    The App results for project #{single_project} are"
  puts "      #{app_results}"

#  app_results.each do |app_res|
#    puts "      # AppResult: #{app_res.id}"
#    files = app_res.get_files(my_api)
#    puts files
#  end

  samples = single_project.get_samples(my_api)
  puts "    The samples for project #{single_project} are"
  puts "      #{samples}"

#  samples.each do |sample|
#    puts "      # Sample: #{sample}"
#    files = sample.get_files(my_api)
#    puts files
#  end
end

# We will take a further look at the files belonging to the sample and 
# analysis from the last project in the loop above.
app_results.each do |app_res|
  puts "# AppResult: #{app_res.id}"
  files = app_res.get_files(my_api)
  puts files
end
samples.each do |sample|
  puts "# Sample: #{sample}"
  files = sample.get_files(my_api)
  puts files
end

# [TODO] We need to identify file IDs for BAM and VCF which can be accessed by everyone (for testing)
# The BAM file 2150156 and the VCF file 2150158 are not available for public
# => Forbidden: Sorry but this requires READ access to this  resource.
#
# https://basespace.illumina.com/datacentral
#
# Project: Cancer Sequencing Demo - id=4
# AppResult: 31193
#   L2I_S1.bam - id: '5595005', size: '673519149'
#
# Project: ResequencingPhixRun - id=12
# AppResult: 6522
#   Indels.1.vcf - id: '3360125', size: '747'
# Project: BaseSpaceDemo - id=2
# AppResult: 1031
#   Indels.1.vcf - id: '535594', size: '5214'
# 

#
# Working with files.
#

# We grab a BAM by id and get the coverage for an interval + accompanying meta-data.
my_bam = my_api.get_file_by_id('5595005')  # [TODO] What file ID to use?
puts "# BAM: #{my_bam}"
cov_meta = my_bam.get_coverage_meta(my_api, 'chr2')
puts cov_meta
cov = my_bam.get_interval_coverage(my_api, 'chr2', '1', '20000')  # [TODO] What seqname and position to use?
puts cov

# and a vcf file
#my_vcf = my_api.get_file_by_id('3360125')  # [TODO] What file ID to use?
my_vcf = my_api.get_file_by_id('44153695')  # Public data >> Resequencing >> HiSeq 2500 2x150 Human Genome Demo
puts "# VCF: #{my_vcf}"
# Let's get the variant meta info 
var_meta = my_vcf.get_variant_meta(my_api)
puts var_meta
#var = my_vcf.filter_variant(my_api, 'phix', '1', '5386')  # [TODO] What seqname and position to use?
var = my_vcf.filter_variant(my_api, '2', '1', '11000')
puts var


