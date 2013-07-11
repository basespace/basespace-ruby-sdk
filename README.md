INTRODUCTION	
=========================================

Bio::BaseSpace is a Ruby based SDK to be used in the development of Apps and scripts for working with Illumina's BaseSpace cloud-computing solution for next-gen sequencing data analysis. 

The primary purpose of the SDK is to provide an easy-to-use Ruby environment enabling developers to authenticate a user, retrieve data, and upload data/results from their own analysis to BaseSpace.

If you haven't already done so, you may wish to familiarize yourself with the general BaseSpace developers documentation (https://developer.basespace.illumina.com/) and create a new BaseSpace App to be used when working through the examples provided in 'examples' folder.

AUTHORS
=========================================

Joachim Baran, Raoul Bonnal, Francesco Strozzi, Toshiaki Katayama

REQUIREMENTS
=========================================

*  Ruby 1.9.3 or newer.
*  Multi-part file upload will currently only work on UNIX operating systems (s.a. Linux or Mac OS X)

INSTALL
=========================================

    git clone git@github.com:joejimbo/basespace-ruby-sdk.git
    export RUBYLIB=/path/to/basespace-ruby-sdk/lib/
    export BASESPACE_CREDENTIALS=/path/to/credentials.json

*  go to the [BaseSpace web site](https://developer.basespace.illumina.com)
*  click on "MyApps" and "Create a new Application"
*  click the new application and open "Credentials" tab
*  copy "Client Id", "Client Secret" and "Access Token" in the JSON file
*  go to Dashboard and click "Public Data" then import "Runs" and "Project"
   *  https://basespace.illumina.com/datacentral
*  go to Dashboard and click "Apps" then "Launch"
   * https://basespace.illumina.com/dashboard
*  you will be navigated to URL containing appsessions/xxxxxxxxxxx
   *  copy "xxxxxxxxxxx" to app_session_id in the JSON file

EXAMPLES
=========================================

Example 1
---------

    #!/usr/bin/env ruby
    
    require 'basespace'

    include Bio::BaseSpace

    bsapi = BaseSpaceAPI.start
    bsapi.get_user_by_id('current')

Example 2
---------

    require 'basespace'
    
    include Bio::BaseSpace
    
    bs = BaseSpaceAPI.start
    
    as = bs.get_app_session
    as.references
    as.user_created_by
    as.references.first
    prj = as.references.first.content
    prj.name
    prj.id
    prj.date_created
    prj.get_access_str('write')
    hash = bs.get_access(prj, 'read')
    hash['verification_with_code_uri']
    hash['device_code']
    
    bs.get_access_token
    user = bs.get_user_by_id('current')
    bs.get_project_by_user('current')
    user.get_projects(bs)
    user.get_runs(bs)
    bs.get_available_genomes
    bs.get_genome_by_id('4')
    projects = bs.get_project_by_user('current')
    
    projects.each do |project|
      results = project.get_app_results(bs)
      
      results.each do |result|
        files = result.get_files(bs)
      end
    
      samples = project.get_samples(bs)
    
      samples.each do |sample|
        files = sample.get_files(bs)
      end
    end
    
    bam = bs.get_file_by_id('5595005')
    bam.get_coverage_meta(bs, 'chr2')
    bam.get_interval_coverage(bs, 'chr2', '1', '20000')
    vcf = bs.get_file_by_id('3360125')
    vcf.get_variant_meta(bs)

BUILDING A NEW VERSION OF THE GEM
=========================================

    bundle exec rake gemspec
    bundle exec gem build bio-basespace.gemspec
    sudo gem install bio-basespace

### Unit Testing

First, install the gem as described just above. Then use [RSpec](http://rspec.info) for unit testing:

    rspec -c -f d

CHANGELOG
=========================================

v 0.1.2
-----------------------------------------
 
Initial Ruby version ported from the v 0.1.2 release of BaseSpacePy

COPYING / LICENSE
=========================================

See License.txt for details on licensing and distribution.

KNOWN BUGS
=========================================

Please refer to our [issue tracker](https://github.com/joejimbo/basespace-ruby-sdk/issues) for a list of known bugs or to submit a new bug report.

