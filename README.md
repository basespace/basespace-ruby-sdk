# BaseSpace Ruby SDK

BaseSpace Ruby SDK is a Ruby based Software Development Kit to be used in the development of Apps and scripts for working with Illumina's BaseSpace cloud-computing solution for next-gen sequencing data analysis.

The primary purpose of the SDK is to provide an easy-to-use Ruby environment enabling developers to authenticate a user, retrieve data, and upload data/results from their own analysis to BaseSpace.

*Note:* For running several of the example below a (free) BaseSpace account is required and you need to have the "Client Id" code (parameter `client_key` below) and "Client Secret" code (parameter `client_secret` below) for one of your Apps available.

**Table of Contents**

*  [BaseSpace Ruby SDK](#basespace-ruby-sdk)
   *  [Availability and Installation](#availability-and-installation)
   *  [Getting Started](#getting-started)
   *  [Application Triggering](#application-triggering)
   *  [BaseSpace Authentication](#basespace-authentication)
   *  [Browsing Data](#browsing-data)
   *  [Accessing and Querying Files](#accessing-and-querying-files)
   *  [Creating an AppResult and Uploading Files](#creating-an-appresult-and-uploading-files)
   *  [Cookbook of Usage Recipes](#cookbook-of-usage-recipes)
   *  [Feature Requests and Bug Reporting](#feature-requests-and-bug-reporting)
*  [SDK Development Manual](#sdk-development-manual)
   *  [Building a New Version of the Gem](#building-a-new-version-of-the-gem)
   *  [Unit Testing](#unit-testing)
   *  [Porting](#porting)
*  [Authors and Contributors](#authors-and-contributors)
   *  [Authors](#authors)
   *  [Contributors](#contributors)
*  [Copying and License](#copying-and-license)

## Availability and Installation

*Requirements:* Ruby 1.9.3 and above. The multi-part file upload will currently only run on a Unix setup.

The production environment version of BaseSpace Ruby SDK is available as a Ruby gem:

    gem install bio-basespace-sdk

Depending on your Ruby installation, it might be necessary to install the Ruby gem with superuser permissions:

    sudo gem install bio-basespace-sdk

To test that everything is working as expected, launch a Interactive Ruby and try importing 'Bio::BaseSpace': 

    $ irb
    >> require 'bio-basespace-sdk'
    >> include Bio::BaseSpace

### Pre-Release Version [![Build Status](https://travis-ci.org/basespace/basespace-ruby-sdk.png?branch=master)](https://travis-ci.org/basespace/basespace-ruby-sdk)

The pre-release version of BaseSpace Ruby SDK can be checked out here:

    git clone https://github.com/basespace/basespace-ruby-sdk.git

or by,

    git clone git@github.com:basespace/basespace-ruby-sdk.git

For a description on how to build the pre-release version see "[SDK Development Manual](#sdk-development-manual)".

Please fork the GitHub repository and send us a pull request if you would like to improve the SDK.

## Getting Started

The core class for interacting with BaseSpace is `Bio::BaseSpace::BaseSpaceAPI`. An instance of the class is created by passing authentication and connection details either via arguments to a `new` call or via the file `credentials.json`.

*Note:* Depending on the actions that you want to carry out, you will either need to provide an App session ID (`app_session_id`) or an access token (`access_token`), or both. You can set one of these parameters to `nil`, if it is not required for your interactions with BaseSpace.

Creating a `BaseSpaceAPI` object using `new`:

    require 'bio-basespace-sdk'
    
    include Bio::BaseSpace
    
    # Authentication and connection details:
    client_id       = '<my client key>'
    client_secret   = '<my client secret>'
    app_session_id  = '<my app session id>'
    access_token    = '<my access token>'
    basespace_url   = 'https://api.basespace.illumina.com/'
    api_version     = 'v1pre3'
    
    # Initialize a BaseSpace API object:
    bs_api = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id, access_token)

Creating a `BaseSpaceAPI` object using `credentials.json`:

    require 'bio-basespace-sdk'
    
    include Bio::BaseSpace
    
    # Initialize a BaseSpace API object with authentication/connection details in 'credentials.json':
    bs_api = BaseSpaceAPI.start

The file `credentials.json` contains the authentication/connection details in [JSON](http://json.org) format:

    {
        "client_id":      "<my client id>",
        "client_secret":  "<my client secret>",
        "app_session_id": "<my app session id>",
        "access_token":   "<my access token>",
        "basespace_url":  "https://api.basespace.illumina.com",
        "api_version":    "v1pre3"
    }

## Application Triggering

**Example Source Code:** [examples/0\_app\_triggering.rb](https://github.com/basespace/basespace-ruby-sdk/blob/master/examples/0_app_triggering.rb)

This section demonstrates how to retrieve the `AppSession` object produced when a user triggers a BaseSpace App. 
Further, we cover how to automatically generate the scope strings to request access to the data object (be it a project or a sample) that the App was triggered to analyze.

The initial HTTP request to our App from BaseSpace is identified by an `AppSession` instance. Using this instance, we are able to obtain information about the user who launched the App and the data that is sought/analyzed by the App. 

*Note:* Create a `BaseSpaceAPI` object as described under "[Getting Started](#getting-started)" first. The instance should be referenced by the variable `bs_api`, just as in the examples of the "[Getting Started](#getting-started)" section.

    # Using bs_api, we can request the AppSession object corresponding to the AppSession ID supplied
    my_app_session = bs_api.get_app_session
    puts my_app_session
    
    # An app session contains a referral to one or more AppSessionLaunchObject instances, which reference the
    # data module the user launched the App on. This can be a list of projects, samples, or a mixture of objects
    puts "Type of data the app was triggered on can be seen in 'references':"
    puts my_app_session.references

The output will be similar to:

    App session by 600602: Eri Kibukawa - Id: <my app session id> - status: Complete
    Type of data the app was triggered on can be seen in 'references':
    Project

We can get a handle to the user who started the `AppSession` and further information on the `AppSessionLaunchObject`:

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

The output will be similar to:

    App session created by user:
    13039: Eri Kibukawa
    
    href to the launch object:
    v1pre3/projects/848850
    
    Type of that object:
    Project

To start working, we will want to expand our permission scope for the trigger object so we can read and write data. The details of this process is the subject of the next section. 
This section shows how one can easily obtain the so-called "scope string" and make the access request. More background reading on scope strings can be found in the BaseSpace developer documentation under "[BaseSpace Permissions](https://developer.basespace.illumina.com/docs/content/documentation/authentication/using-scope)".

    puts "Project object:" 
    my_reference_content =  my_reference.content
    puts my_reference_content
    puts
    puts "Scope string for requesting write access to the reference object:"
    puts my_reference_content.get_access_str('write')

The output will be similar to:

    Project object:
    MyProject - id=848850
    
    Scope string for requesting write access to the reference object:
    write project 848850

We can request write access to the reference object now, so that our App can start contributing to an analysis.

The following call requests write permissions:

    access_map = bs_api.get_access(my_reference_content, 'write')
    puts "Access map:"
    puts access_map

The output will be similar to:

    Access map:
    {"device_code"=>"<my device code>", "user_code"=>"<my user code>", "verification_uri"=>"https://basespace.illumina.com/oauth/device", "verification_with_code_uri"=>"https://basespace.illumina.com/oauth/device?code=<my user code>", "expires_in"=>1800, "interval"=>1}

Have the user visit the verification URI to grant us access:

    puts "Visit the URI within 15 seconds and grant access:"
    verification_with_code_uri = access_map['verification_with_code_uri']
    puts verification_with_code_uri

The output will be:

    Visit the URI within 15 seconds and grant access:
    https://basespace.illumina.com/oauth/device?code=<my user code>

The URI can be opened in a web browser using this portable Ruby code:

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

Once the user has granted us access to objects we requested we can get the BaseSpace access-token and start browsing simply by calling `update_privileges` on the `BaseSpaceAPI` instance:

    code = access_map['device_code']
    bs_api.update_privileges(code)

For more details on access-requests and authentication and an example of the web-based case see example [1\_authentication.rb](https://github.com/basespace/basespace-ruby-sdk/blob/master/examples/1_authentication.rb)

## BaseSpace Authentication

**Example Source Code:** [examples/1\_authentication.rb](https://github.com/basespace/basespace-ruby-sdk/blob/master/examples/1_authentication.rb) and [examples/2\_browsing.rb](https://github.com/basespace/basespace-ruby-sdk/blob/master/examples/2_browsing.rb)

Here we demonstrate the basic BaseSpace authentication process. The workflow outlined here is

1. Request of access to a specific data-scope 
2. User approval of access request 
3. Browsing data

It will be useful if you are logged in to the BaseSpace web-site before launching this example to make the access granting procedure faster.

*Note:* Create a `BaseSpaceAPI` object as described under "[Getting Started](#getting-started)" first. The instance should be referenced by the variable `bs_api`, just as in the examples of the "[Getting Started](#getting-started)" section.

### Requesting Access Privileges

First, get the verification code and URI for scope 'browse global':

    access_map = bs_api.get_verification_code('browse global')
    puts "URI for user to visit and grant access:"
    puts access_map['verification_with_code_uri']

At this point the user must visit the verification URI to grant the requested privilege. From Ruby, it is possible to launch a browser pointing to the verification URI using:

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
    sleep(15)

The output will be:

    URI for user to visit and grant access: 
    https://basespace.illumina.com/oauth/device?code=<my code>
    
Once access has been granted, we can get the BaseSpace `access_token` and start browsing simply by calling `update_privileges` on the baseSpaceApi instance.

    code = access_map['device_code']
    bs_api.update_privileges(code)

As a reference the provided access-token can be obtained from the `BaseSpaceAPI` object:

    puts "Access-token: #{bs_api.get_access_token}"

The output will be:

    Access-token: <my access-token>

## Browsing Data

This section demonstrates basic browsing of BaseSpace objects once an access-token for global browsing has been obtained. We will see how objects can be retrieved using either the `BaseSpaceAPI` class or by use of method calls on related object instances (for example, `User` instances can be used to retrieve all projects belonging to that user).

*Note:* Create a `BaseSpaceAPI` object as described under "[Getting Started](#getting-started)" first. The instance should be referenced by the variable `bs_api`, just as in the examples of the "[Getting Started](#getting-started)" section.

First, we will try to retrieve a genome object:

    my_genome = bs_api.get_genome_by_id('4')
    puts "Genome: #{my_genome}"
    puts "Id: #{my_genome.id}"
    puts "Href: #{my_genome.href}"
    puts "DisplayName: #{my_genome.display_name}"

The output will be:

    Genome: Homo sapiens
    Id: 4
    Href: v1pre3/genomes/4
    DisplayName: Homo Sapiens - UCSC (hg19)

We can get a list of all available genomes:

    all_genomes  = bs_api.get_available_genomes
    puts "Genomes: #{all_genomes.map { |g| g.to_s }.join(', ')}"

The output will be:

    Genomes: Arabidopsis thaliana, Bos Taurus, Escherichia coli, Homo sapiens, Mus musculus, Phix, Rhodobacter sphaeroides, Rattus norvegicus, Saccharomyces cerevisiae, Staphylococcus aureus

Now, retrieve the `User` object for the current user and list all projects for this user:

    user = bs_api.get_user_by_id('current')
    puts "User -- #{user}"
    
    my_projects = bs_api.get_project_by_user('current')
    puts "Projects: #{my_projects.map { |p| p.to_s }.join(', ')}"

The output will be similar to:

    User -- <user id>: <user name>
    Projects: IGN_WGS_CEPH_Services_2.0 - id=267267

We can also achieve this by making a call to the `User` instance:

    my_projects = user.get_projects(bs_api)
    puts "Projects: #{my_projects.map { |p| p.to_s }.join(', ')}"

The output will be as above:

    User -- <user id>: <user name>
    Projects: IGN_WGS_CEPH_Services_2.0 - id=267267

We can also list all runs for a user:

    runs = user.get_runs(bs_api)
    puts "Runs: #{runs.map { |r| r.to_s }.join(', ')}"

The output will be similar to:

    Runs: BaseSpaceDemo - id=2, Cancer Sequencing Demo - id=4, HiSeq 2500 - id=7, ResequencingPhixRun - id=12, TSChIP-Seq - id=14042, BCereusDemoData_Illumina - id=34061
    
## Accessing and Querying Files

**Example Source Code:** [examples/3\_accessing\_files.rb](https://github.com/basespace/basespace-ruby-sdk/blob/master/examples/3_accessing_files.rb)

In this section we demonstrate how to access samples and analysis from a projects and how to work with the available file data for such instances. In addition, we take a look at some of the special queuring methods associated with BAM- and VCF-files. 

*Note:* Create a `BaseSpaceAPI` object as described under "[Getting Started](#getting-started)" first. The instance should be referenced by the variable `bs_api`, just as in the examples of the "[Getting Started](#getting-started)" section.

### Accessing Files

First, we get a project that we can work with:

    user = bs_api.get_user_by_id('current')
    my_projects = bs_api.get_project_by_user('current')

Now we can list all the analyses and samples for these projects:

    # Define 'samples' variable here, so that it can be reused further into the example again:
    samples = nil
    my_projects.each do |single_project|
      puts "Project: #{single_project}"
      
      app_results = single_project.get_app_results(bs_api)
      puts "  AppResult instances: #{app_results.map { |r| r.to_s }.join(', ')}"
      
      samples = single_project.get_samples(bs_api)
      puts "  Sample instances: #{samples.map { |s| s.to_s }.join(', ')}"
    end

The output will be similar to:

    Project: BaseSpaceDemo - id=2
      AppResult instances: Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing
      Sample instances: BC_1, BC_2, BC_3, BC_4, BC_5, BC_6, BC_7, BC_8, BC_9, BC_10
    Project: Cancer Sequencing Demo - id=4
      AppResult instances: Amplicon, Amplicon
      Sample instances: L2I
    Project: HiSeq 2500 - id=7
      AppResult instances: Resequencing
      Sample instances: NA18507

We will take a further look at the files belonging to the sample from the last project in the loop above:

    samples.each do |sample|
      puts "Sample: #{sample}"
      files = sample.get_files(bs_api)
      puts files.map { |f| "  #{f}" }
    end

The output will be similar to:

    Sample: Bcereus_1
      Bcereus-1_S1_L001_R1_001.fastq.gz - id: '14235852', size: '179971155'
      Bcereus-1_S1_L001_R2_001.fastq.gz - id: '14235853', size: '193698522'
    Sample: Bcereus_2
      Bcereus-2_S2_L001_R1_001.fastq.gz - id: '14235871', size: '126164153'
      Bcereus-2_S2_L001_R2_001.fastq.gz - id: '14235872', size: '137077949'

### Querying BAM and VCF Files

Now, we have a look at some of the methods calls specific to BAM and VCF files. First, we will get a BAM-file and then retrieve the coverage information available for chromosome 2 between positions 1 and 20000: 

    # Request privileges:
    # NOTE THAT YOUR PROJECT ID (469469 here) WILL MOST LIKELY BE DIFFERENT!
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
    
    # Get the coverage for an interval + accompanying meta-data:
    # NOTE THAT YOUR FILE ID (here 7823816) WILL MOST LIKELY BE DIFFERENT!
    # A FILE ID CAN BE OBTAINED, E.G., USING: samples.first.get_files(bs_api).first.id
    my_bam = bs_api.get_file_by_id('7823816')
    puts "BAM: #{my_bam}"
    cov = my_bam.get_interval_coverage(bs_api, 'chr1', '50000', '60000')
    puts "  #{cov.to_s}"
    cov_meta = my_bam.get_coverage_meta(bs_api, 'chr1')
    puts "  #{cov_meta.to_s}"

The output will be similar to:

    BAM: sorted_S1.bam - id: '44154664', size: '105789387933', status: 'complete'
      Chrom chr1: 1-1792, BucketSize=2
      CoverageMeta: max=1158602 gran=128

For VCF-files we can filter variant calls based on chromosome and location as well:

    my_vcf = bs_api.get_file_by_id('7823817')
    var_meta = my_vcf.get_variant_meta(bs_api)
    puts var_meta
    var = my_vcf.filter_variant(bs_api, '1', '20000', '30000') # no value. need verification
    puts "  #{var.map { |v| v.to_s }.join(', ')}"

The output will be:

    VariantHeader: SampleCount=1
      Variant - chr2: 10236 id=['.'], Variant - chr2: 10249 id=['.']

## Creating an AppResult and Uploading Files

**Example Source Code:** [4\_app\_result\_upload.rb](https://github.com/basespace/basespace-ruby-sdk/blob/master/examples/4_app_result_upload.rb)

In this section we will see how to create a new `AppResult` object, change the state of the related AppSession,
and upload result files to it as well as retrieve files from it. 

*Note:* Create a `BaseSpaceAPI` object as described under "[Getting Started](#getting-started)" first. The instance should be referenced by the variable `bs_api`, just as in the examples of the "[Getting Started](#getting-started)" section.

### Creating an AppResult

First we get a project to work on. We will need write permissions for the project we are working on -- meaning that we will need to update our privileges accordingly:
    
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
    
    # NOTE THAT YOUR PROJECT ID WILL MOST LIKELY BE DIFFERENT!
    # YOU CAN GET IT VIA THE SDK OR FROM THE BASESPACE WEB INTERFACE!
    # FOR EXAMPLE: my_projects.first.id
    prj = bs_api.get_project_by_id('469469')

Assuming we have write access for the project, we will list the current analyses for the project:

    statuses = ['Running']
    app_res = prj.get_app_results(bs_api, {}, statuses)
    puts "AppResult instances: #{app_res.map { |r| r.to_s }.join(', ')}"

The output will be similar to:

    AppResult instances: BWA GATK - HiSeq 2500 NA12878 demo 2x150, HiSeq 2500 NA12878 demo 2x150 App Result

To create an `AppResult` for a project, request 'create' privileges, then simply give the name and description:

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

The output will be similar to:

    AppResult ID: 939946
    AppResult's AppSession: App session by 159159: Eri Kibukawa - Id: <app session id> - status: Running

We can change the status of our `AppSession` and add a status-summary as follows:

    app_result.app_session.set_status(bs_api, 'needsattention', "We worked hard, but encountered some trouble.")

    # Updated status:
    puts "AppResult's AppSession: #{app_result.app_session}"

    # Set back to running:
    app_result.app_session.set_status(bs_api, 'running', "Back on track")

The output will be similar to:

    AppResult's AppSession: App session by 159159: Eri Kibukawa - Id: <app session id> - status: NeedsAttention

### Uploading Files

Attach a file to the `AppResult` object and upload it:

    app_result.upload_file(bs_api, '/tmp/testFile.txt', 'BaseSpaceTestFile.txt', '/mydir/', 'text/plain')
    
    # Let's see if our new file made it into the cloud:
    app_result_files = app_result.get_files(bs_api)
    puts "Files: #{app_result_files.map { |f| f.to_s }.join(', ')}"

The output will be:

    Files: BaseSpaceTestFile.txt - id: '7819953', size: '5'

Of course, we can download our newly uploaded file too:

    f = bs_api.get_file_by_id(app_result_files.last.id)
    f.download_file(bs_api, '/tmp/')

## Cookbook of Usage Recipes

This section contains useful code snippets, which are demonstrating frequent use-cases in App development.

### Filtering File-Lists and AppResult-Lists using Query Parameter Dictionaries

Given a sample "a\_sample" we can retrieve a subset of the full file-list using a query parameter dictionary:

*Note:* Create a `BaseSpaceAPI` object as described under "[Getting Started](#getting-started)" first. The instance should be referenced by the variable `bs_api`, just as in the examples of the "[Getting Started](#getting-started)" section.

    # With a BaseSpace API object created as shown above, retrieve a list of our projects,
    # pick the first available project, get its samples, and then assign the first sample
    # to the variable `a_sample`.
    my_projects = bs_api.get_project_by_user('current')
    a_project = my_projects.first
    my_samples = a_project.get_samples(bs_api)
    
    # Get a brief sample representation from the point of a project:
    a_sample = my_samples.first
    
    # Get the full version via direct BaseSpace API call (for demonstration, not required below):
    full_sample = bs_api.get_sample_by_id(a_sample.id)
    
    # Get a list of files associated with the sample:
    # Possible output: ["s_G1_L001_I1_001.fastq.1.gz - id: '535642', size: '7493990'", "s_G1_L001_I1_002.fastq.1.gz - id: '535643', size: '7525743'"]
    a_sample.get_files(bs_api).map { |file| file.to_s }
    
    # Get a listing of ".gz" files:
    a_sample.get_files(bs_api, { 'Extensions' => 'gz' })
    
    # Get a listing with multiple extension filter (".bam" and ".vcf" files):
    a_sample.get_files(bs_api, { 'Extensions' => 'bam,vcf' })

You can provide all other legal sorting/filtering keyword in this dictionary to get further refinement of the list:

    a_sample.get_files(bs_api, { 'Extensions' => 'bam,vcf', 'SortBy' => 'Path', 'Limit' => 1 })

You can supply a dictionary of query parameters when retrieving App results, in the same way you filter file lists. Below is an example of how to limit the number of results from 100 (default value for "Limit") to 10.

    results = a_project.get_app_results(bs_api)
    
    # Possible output: 100
    results.length
    
    # Restrict the returned list of results to 10 items.
    # New length of `results`: 10
    results = a_project.get_app_results(bs_api, { 'Limit' => '10' })
    results.length

## Feature Requests and Bug Reporting

Please report any feedback regarding the BaseSpace Ruby SDK directly to the [GitHub repository](https://github.com/basespace/basespace-ruby-sdk). We appreciate any and all feedback about the SDKs and we will do anything we can to improve the functionality and quality of the SDK to make it the best SDK for developers to use. 

# SDK Development Manual

This section focuses on development aspects of the BaseSpace Ruby SDK gem. It also provides information on how to build the pre-release version of the SDK, but unless you are actually planning to contribute to the SDK source code or documentation, we strongly suggest to follow the official release installation instruction under "[Availability and Installation](#availability-and-installation)".

## Building a New Version of the Gem

    bundle exec rake gemspec
    bundle exec gem build bio-basespace.gemspec
    sudo gem install bio-basespace

## Unit Testing

First, install the gem as described just above. Then use [RSpec](http://rspec.info) for unit testing:

    rspec -c -f d

## Porting

BaseSpace Ruby SDK was initially ported by translating the BaseSpace Python SDK to Ruby. If it becomes necessary to port further code from the Python SDK, then the following porting guidelines should be observed:

*  indentation: Python 4 spaces, Ruby 2 spaces
*  compund words: Python `ExampleLabel`, Ruby `example_label`
*  constructors: Python `def __init__(self):`, Ruby `def initialize`
*  class variables: Python `self.swaggerTypes = { "Key":"value" }`, Ruby `@swagger_types = { "Key" => "value" }`
*  void types: Python `None`, Ruby `nil`
*  string representation: Python `__str__(self)`, Ruby `to_s (return @val.to_s)`
*  object dump: Python `__repr__(self)`, Ruby `to_str (return self.inspect)` or `self.attributes.inspect` for attribute values
*  exceptions: Python `FooBarException` -> `FooBarError`
*  types:
   *  Python `str`, Ruby `String`
   *  Python `int`, Ruby `Integer`
   *  Python `float`, Ruby `Float`
   *  Python `bool`, Ruby `true`/`false`
   *  Python `list<>`, Ruby `Array`
   *  Python `dict`, Ruby `Hash`
   *  Python `file`, Ruby `File`

# Authors and Contributors

## Authors

Joachim Baran, Raoul Bonnal, Eri Kibukawa, Francesco Strozzi, Toshiaki Katayama

## Contributors

In alphabetical order (last name):

*  Joachim Baran
*  Raoul Bonnal
*  Naohisa Goto
*  Toshiaki Katayama
*  Eri Kibukawa
*  Francesco Strozzi

# Copying and License

See [License.txt](https://raw.github.com/basespace/basespace-ruby-sdk/master/License.txt) for details on licensing and distribution.


