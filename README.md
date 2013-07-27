# BaseSpace Ruby SDK

BaseSpace Ruby SDK is a Ruby based Software Development Kit to be used in the development of Apps and scripts for working with Illumina's BaseSpace cloud-computing solution for next-gen sequencing data analysis.

The primary purpose of the SDK is to provide an easy-to-use Ruby environment enabling developers to authenticate a user, retrieve data, and upload data/results from their own analysis to BaseSpace.

*Note:* For running several of the example below a (free) BaseSpace account is required and you need to have the ``client_key`` and ``client_secret`` codes for one of your Apps available.

## Availability

*Note:* We are still testing our code. Please take the production-ready gem with a pinch of salt.

The production environment version of BaseSpace Ruby SDK is available as a Ruby gem:

    gem install bio-basespace-sdk

Depending on your Ruby installation, it might be necessary to install the Ruby gem with superuser permissions:

    sudo gem install bio-basespace-sdk

### Pre-Release Version

The pre-release version of BaseSpace Ruby SDK can be checked out here:

    git clone https://github.com/joejimbo/basespace-ruby-sdk.git

or by,

    git clone git@github.com:joejimbo/basespace-ruby-sdk.git

Status: [![Build Status](https://travis-ci.org/joejimbo/basespace-ruby-sdk.png?branch=master)](https://travis-ci.org/joejimbo/basespace-ruby-sdk)

## Setup

*Requirements:* Ruby 1.9.3 and above. The multi-part file upload will currently only run on a Unix setup.

You can include 'Bio::BaseSpace' by setting below environmental variable: 

    export RUBYLIB=/path/to/basespace-ruby-sdk/lib/

or add it to your Ruby scripts using Bio::BaseSpace:

    $: << '/path/to/basespace-ruby-sdk/lib/'

To test that everything is working as expected, launch a Interactive Ruby and try importing 'Bio::BaseSpace': 

    $ irb
    >> require 'bio-basespace-sdk'
    >> include Bio::BaseSpace

## Getting Started

The core class for interacting with BaseSpace is `Bio::BaseSpace::BaseSpaceAPI`. An instance of the class is created by passing authentication and connection details either via arguments to a `new` call or via the file `credentials.json`.

*Note:* Depending on the actions that you want to carry out, you will either need to provide an App session ID (`app_session_id`) or an access token (`access_token`), or both. You can set one of these parameters to `nil`, if it is not required for your interactions with BaseSpace.

Creating a `BaseSpaceAPI` object using `new`:

    require 'bio-basespace-sdk'
    
    include Bio::BaseSpace
    
    # Authentication and connection details:
    client_id       = 'my client key'
    client_secret   = 'my client secret'
    app_session_id  = 'my app session id'
    access_token    = 'my access token'
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
        "client_id":      "my client id",
        "client_secret":  "my client secret",
        "app_session_id": "my app session id",
        "access_token":   "my access token",
        "basespace_url":  "https://api.basespace.illumina.com",
        "api_version":    "v1pre3"
    }

## Application Triggering

This section demonstrates how to retrieve the ``AppSession`` object produced when a user triggers a BaseSpace App. 
Further, we cover how to automatically generate the scope strings to request access to the data object (be it a project or a sample) that the App was triggered to analyze.

The initial http request to our App from BaseSpace is identified by an ``ApplicationActionId``, using this piece of information 
we are able to obtain information about the user who launched the App and the data that is sought/analyzed by the App. 
First, we instantiate a BaseSpaceAPI object using the ``client_key`` and ``client_secret`` codes provided on the BaseSpace developer's website when registering our App, as well as the ``AppSessionId`` generated from the app-triggering: 

    require 'bio-basespace-sdk'
    
    include Bio::BaseSpace
    
    # Initialize an authentication object using the key and secret from your app:
    client_id       = 'my client key'
    client_secret   = 'my client secret'
    app_session_id  = 'my app session id'
    basespace_url   = 'https://api.basespace.illumina.com/'
    api_version     = 'v1pre3'
    
    # First we will initialize a BaseSpace API object using our app information and the app_session_id
    bs_api = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id)
    
    # Using bs_api, we can request the appSession object corresponding to the AppSession ID supplied
    my_app_session = bs_api.get_app_session
    puts my_app_session
    
    # An app session contains a referal to one or more appLaunchObjects which reference the data module
    # the user launched the app on. This can be a list of projects, samples, or a mixture of objects
    puts "Type of data the app was triggered on can be seen in 'references'"
    puts my_app_session.references.inspect  # `inspect` shows the object contents

The output will be similar to:

    App session by 600602: Eri Kibukawa - Id: <my app session id> - status: Complete
    Type of data the app was triggered on can be seen in 'references'
    [#<Bio::BaseSpace::AppSessionLaunchObject:0x007fc21a1ae0f8 @swagger_types={"Content"=>"dict", "Href"=>"str", "HrefContent"=>"str", "Rel"=>"str", "Type"=>"str"}, @attributes={"Content"=>#<Bio::BaseSpace::Project:0x007fc21a1ae378 @swagger_types={"Name"=>"str", "HrefSamples"=>"str", "HrefAppResults"=>"str", "HrefBaseSpaceUI"=>"str", "DateCreated"=>"datetime", "Id"=>"str", "Href"=>"str", "UserOwnedBy"=>"UserCompact"}, @attributes={"Name"=>"IGN_WGS_CEPH_Services_2.0", "HrefSamples"=>nil, "HrefAppResults"=>nil, "HrefBaseSpaceUI"=>nil, "DateCreated"=>#<DateTime: 2013-04-19T18:21:50+00:00 ((2456402j,66110s,0n),+0s,2299161j)>, "Id"=>"267267", "Href"=>"v1pre3/projects/267267", "UserOwnedBy"=>#<Bio::BaseSpace::UserCompact:0x007fc21a1ac758 @swagger_types={"Name"=>"str", "Id"=>"str", "Href"=>"str"}, @attributes={"Name"=>"Illumina Inc", "Id"=>"3004", "Href"=>"v1pre3/users/3004"}>}>, "Href"=>"v1pre3/projects/267267", "HrefContent"=>"v1pre3/projects/267267", "Rel"=>"Input", "Type"=>"Project"}>]

We can also get a handle to the user who started the AppSession and further information on the ``AppLaunchObject``:

    # We can also get a handle to the user who started the AppSession
    puts "We can get a handle for the user who triggered the app:"
    puts my_app_session.user_created_by
    puts
    
    # Let's have a closer look at the appSessionLaunchObject
    my_reference = my_app_session.references.first
    
    puts "We can get out information such as the href to the launch object:"
    puts my_reference.href_content
    puts
    puts "The specific type of that object:"
    puts my_reference.type
    puts

The output will be:

    We can get a handle for the user who triggered the app:
    13039: Eri Kibukawa
    
    We can get out information such as the href to the launch object:
    v1pre3/projects/848850
    
    The specific type of that object:
    Project

To start working, we will want to expand our permission scope for the trigger object so we can read and write data. The details of this process is the subject of the next section. 
We end this section by demonstrating how one can easily obtain the so-called "scope string" and make the access request:

    puts "\nWe can get out the specific project objects by using 'content':" 
    my_reference_content =  my_reference.content
    puts my_reference_content
    puts "\nThe scope string for requesting write access to the reference object is:"
    puts my_reference_content.get_access_str('write')

The output will be:

    We can get out the specific project objects by using 'content':
    MyProject - id=848850
    
    The scope string for requesting write access to the reference object is:
    write project 848850

We can easily request write access to the reference object, so that our App can start contributing to an analysis
by default. We ask for write permission and authentication for a device:

    access_map = bs_api.get_access(my_reference_content, 'write')
    puts "We get the following access map:"
    puts access_map

The output will be similar to:

    We get the following access map:
    {"device_code"=>"<my device code>", "user_code"=>"<my user code>", "verification_uri"=>"https://basespace.illumina.com/oauth/device", "verification_with_code_uri"=>"https://basespace.illumina.com/oauth/device?code=<my user code>", "expires_in"=>1800, "interval"=>1}

Have the user visit the verification URI to grant us access:

    puts "\nPlease visit the uri within 15 seconds and grant access:"
    puts access_map['verification_with_code_uri']

The output will be:

    Please visit the uri within 15 seconds and grant access:
    https://basespace.illumina.com/oauth/device?code=<my user code>

Accept for this test code through web browser

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

Once the user has granted us access to objects we requested we can get the BaseSpace access-token and start browsing simply by calling ``updatePriviliges`` on the ``baseSpaceApi`` instance:

    code = access_map['device_code']
    bs_api.update_privileges(code)
    puts "The BaseSpaceAPI instance was update with write privileges"

The output will be:

    The BaseSpaceAPI instance was update with write privileges

For more details on access-requests and authentication and an example of the web-based case see example 1\_authentication.rb

## Requesting an Access-Token for Data Browsing

Here we demonstrate the basic BaseSpace authentication process. The workflow outlined here is

1. Request of access to a specific data-scope 
2. User approval of access request 
3. Browsing data

*Note:* It will be useful if you are logged in to the BaseSpace web-site before launching this example to make the access grant procedure faster.

Again, we will start out by initializing a ``BaseSpaceAPI`` object:

    require 'bio-basespace-sdk'
    include Bio::BaseSpace
    
    client_id       = 'my client key'
    client_secret   = 'my client secret'
    app_session_id  = 'my app session id'
    basespace_url   = 'https://api.basespace.illumina.com/'
    api_version     = 'v1pre3'
    
    # First we will initialize a BaseSpace API object using our app information and the appSessionId
    bs_api = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id)

First, get the verification code and uri for scope 'browse global'

    device_info = bs_api.get_verification_code('browse global')
    puts
    puts "URI for user to visit and grant access:"
    puts device_info['verification_with_code_uri']

At this point the user must visit the verification uri to grant us access

    ## PAUSE HERE
    # Have the user visit the verification URI to grant us access
    puts "\nPlease visit the URI within 15 seconds and grant access:"
    puts device_info['verification_with_code_uri']
    
    link = device_info['verification_with_code_uri']
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
    ## PAUSE HERE

The output will be:

    URI for user to visit and grant access: 
    https://basespace.illumina.com/oauth/device?code=<my code>
    
    Please visit the URI within 15 seconds and grant access:
    https://basespace.illumina.com/oauth/device?code=<my code>

Once the user has granted us access to objects we requested, we can get the basespace access_token and start browsing simply by calling ``updatePriviliges`` on the baseSpaceApi instance.

    code = device_info['device_code']
    bs_api.update_privileges(code)

As a reference the provided access-token can be obtained from the BaseSpaceApi object

    puts "My Access-token: #{bs_api.get_access_token}"
    puts

The output will be:

    My Access-token:
    <my access-token>

At this point we can start using the ``BaseSpaceAPI`` instance to browse the available data for the current user, the details of this process is the subject of the next section. Here we will end with showing how the API object can be used to list all BaseSpace genome instances: 

    # We will get all available genomes with our new api! 
    all_genomes  = bs_api.get_available_genomes
    puts "Genomes: #{all_genomes.map { |g| g.to_s }.join(', ')}"

The output will be:

    Genomes: Arabidopsis thaliana, Bos Taurus, Escherichia coli, Homo sapiens, Mus musculus, Phix, Rhodobacter sphaeroides, Rattus norvegicus, Saccharomyces cerevisiae, Staphylococcus aureus

## Browsing Data with Global Browse Access

This section demonstrates basic browsing of BaseSpace objects once an access-token for global browsing has been obtained. We will see how 
objects can be retrieved using either the ``BaseSpaceAPI`` class or by use of method calls on related object instances (for example once 
a ``user`` instance we can use it to retrieve all project belonging to that user).

First we will initialize a ``BaseSpaceAPI`` using our access-token for ``global browse``:

    require 'bio-basespace-sdk'
    include Bio::BaseSpace
    
    # REST server information and user access_token 
    
    client_id       = 'my client key'
    client_secret   = 'my client secret'
    access_token    = 'your access token'
    app_session_id  = 'my app session id'
    basespace_url   = 'https://api.basespace.illumina.com/'
    api_version     = 'v1pre3'
    
    # First, create a client for making calls for this user session
    bs_api = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id, access_token)

First we will try to retrieve a genome object:

    # Now grab the genome with id=4
    my_genome = bs_api.get_genome_by_id('4')
    puts "The Genome is #{my_genome}"
    puts "We can get more information from the genome object"
    puts "Id: #{my_genome.id}"
    puts "Href: #{my_genome.href}"
    puts "DisplayName: #{my_genome.display_name}"

The output will be:

    The Genome is Homo sapiens
    We can get more information from the genome object
    Id: 4
    Href: v1pre3/genomes/4
    DisplayName: Homo Sapiens - UCSC (hg19)

Using a comparable method we can get a list of all available genomes:

    # Get a list of all genomes
    all_genomes  = bs_api.get_available_genomes
    puts "Genomes: #{all_genomes}"

The output will be:

    Genomes 
    [Arabidopsis thaliana, Bos Taurus, Escherichia coli, Homo sapiens, Mus musculus, Phix,\
     Rhodobacter sphaeroides, Rattus norvegicus, Saccharomyces cerevisiae, Staphylococcus aureus]

Now, let us retrieve the ``User`` objects for the current user, and list all projects for this user:

    # Take a look at the current user
    user = bs_api.get_user_by_id('current')
    puts "The current user is #{user}"
    puts
    
    # Now list the projects for this user
    my_projects = bs_api.get_project_by_user('current')
    puts "The projects for this user are #{my_projects}"
    puts

The output will be:

    [BaseSpaceDemo - id=2, Cancer Sequencing Demo - id=4, HiSeq 2500 - id=7, ResequencingPhixRun - id=12, TrainingRun - id=114, Note - id=165, 120313-tra - id=606, S.abortusequi-17_L2508 - id=619, TSChIP-Seq - id=14042, BCereusDemoData_Illumina - id=34061]
    
    The current user is 
    <user id>: Your Name
    
    The projects for this user are 
    [BaseSpaceDemo - id=2, Cancer Sequencing Demo - id=4, HiSeq 2500 - id=7, ResequencingPhixRun - id=12, TSChIP-Seq - id=14042, BCereusDemoData_Illumina - id=34061]

We can also achieve this by making a call using the ``user`` instance. Notice that these calls take an instance of ``BaseSpaceAPI`` with apporpriate 
priviliges to complete the transaction as parameter, this true for all retrieval method calls made on data objects:

    my_projects2 = user.get_projects(bs_api)
    puts "Projects retrieved from the user instance"
    puts my_projects2
    
    # List the runs available for the current user
    runs = user.get_runs(bs_api)
    puts "The runs for this user are"
    puts runs

The output will be:

    Projects retrieved from the user instance
    [BaseSpaceDemo - id=2, Cancer Sequencing Demo - id=4, HiSeq 2500 - id=7, ResequencingPhixRun - id=12, TSChIP-Seq - id=14042, BCereusDemoData_Illumina - id=34061]
    
    The runs for this user are
    [BacillusCereus, Genome-in-a-Day, TSCA_test, 2x151PhiX, TruSeq Amplicon_Cancer Panel, CancerDemo]
    
In the same manner we can get a list of accessible user runs:

    runs = user.get_runs(bs_api)
    puts "Runs retrieved from user instance"
    puts runs

The output will be:

    Runs retrieved from user instance 
    [BacillusCereus, Genome-in-a-Day, TSCA_test, 2x151PhiX, TruSeq Amplicon_Cancer Panel, CancerDemo]

## Accessing File-Trees and Querying BAM/VCF Files

In this section we demonstrate how to access samples and analysis from a projects and how to work with the available file data for such instances.
In addition, we take a look at some of the special queuring methods associated with BAM- and VCF-files. 

Again, start out by initializing a ``BaseSpaceAPI`` instance and retrieving all projects belonging to the current user:

    # First, create a client for making calls for this user session 
    require 'bio-basespace-sdk'
    include Bio::BaseSpace
    
    client_id       = 'my client key'
    client_secret   = 'my client secret'
    access_token    = 'your access token'
    app_session_id  = 'my app session id'
    basespace_url   = 'https://api.basespace.illumina.com/'
    api_version     = 'v1pre3'
    
    bs_api       = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id, access_token)
    user         = bs_api.get_user_by_id('current')
    my_projects  = bs_api.get_project_by_user('current')
    
    app_results  = nil
    samples      = nil

Now we can list all the analyses and samples for these projects

    # Let's list all the AppResults and samples for these projects
    
    my_projects.each do |single_project|
      puts "# Project: #{single_project}"
      
      app_results = single_project.get_app_results(bs_api)
      puts "    The App results for project #{single_project} are"
      puts "      #{app_results}"
      
      samples = single_project.get_samples(bs_api)
      puts "    The samples for project #{single_project} are"
      puts "      #{samples}"
    end

The output will be:

    # Project: BaseSpaceDemo - id=2
         The App results for project BaseSpaceDemo - id=2 are
           [Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing, Resequencing]
         The samples for project BaseSpaceDemo - id=2 are
           [BC_1, BC_2, BC_3, BC_4, BC_5, BC_6, BC_7, BC_8, BC_9, BC_10]
    # Project: Cancer Sequencing Demo - id=4
         The App results for project Cancer Sequencing Demo - id=4 are
           [Amplicon, Amplicon]
         The samples for project Cancer Sequencing Demo - id=4 are
           [L2I]
    # Project: HiSeq 2500 - id=7
         The App results for project HiSeq 2500 - id=7 are
           [Resequencing]
         The samples for project HiSeq 2500 - id=7 are
           [NA18507]
    ......

We'll take a further look at the files belonging to the sample from the last project in the loop above:

    samples.each do |sample|
        puts "# Sample: #{sample}"
        files = sample.get_files(bs_api)
        puts files
    end

The output will be:

    # Sample: Bcereus_1
    Bcereus-1_S1_L001_R1_001.fastq.gz - id: '14235852', size: '179971155'
    Bcereus-1_S1_L001_R2_001.fastq.gz - id: '14235853', size: '193698522'
    # Sample: Bcereus_2
    Bcereus-2_S2_L001_R1_001.fastq.gz - id: '14235871', size: '126164153'
    Bcereus-2_S2_L001_R2_001.fastq.gz - id: '14235872', size: '137077949'
    ......

Now, have a look at some of the methods calls specific to ``Bam`` and ``VCF`` files. First, we will get a ``Bam``-file and then retrieve the coverage information available for chromosome 2 between positions 1 and 20000: 

    device_info = bs_api.get_verification_code('read project 183184')
    link = device_info['verification_with_code_uri']
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
    
    code = device_info['device_code']
    bs_api.update_privileges(code)
    
    # Now do some work with files 
    # we'll grab a BAM by id and get the coverage for an interval + accompanying meta-data 
    
    my_bam = bs_api.get_file_by_id('44154664')
    puts "# BAM: #{my_bam}"
    cov = my_bam.get_interval_coverage(bs_api, 'chr1', '50000', '60000')
    puts cov
    cov_meta = my_bam.get_coverage_meta(bs_api, 'chr1')
    puts cov_meta

The output will be:

    # BAM: sorted_S1.bam - id: '44154664', size: '105789387933', status: 'complete'
    Chrom chr1: 1-1792, BucketSize=2
    CoverageMeta: max=1158602 gran=128

For ``VCF``-files we can filter variant calls based on chromosome and location as well:

    # and a vcf file
    my_vcf = bs_api.get_file_by_id('44154644')
    
    # Get the variant meta info 
    
    var_meta = my_vcf.get_variant_meta(bs_api)
    puts var_meta
    var = my_vcf.filter_variant(bs_api, '1', '20000', '30000') # no value. need verification
    puts var

The output will be:

    VariantHeader: SampleCount=1
    [Variant - chr2: 10236 id=['.'], Variant - chr2: 10249 id=['.'], ....]

## Creating an AppResult and Uploading Files

In this section we will see how to create a new AppResults object, change the state of the related AppSession,
and upload result files to it as well as retrieve files from it. 

First, create a client for making calls for this user session:

    require 'bio-basespace-sdk'
    include Bio::BaseSpace
    
    client_id       = 'my client key'
    client_secret   = 'my client secret'
    app_session_id  = 'my app session id'
    basespace_url   = 'https://api.basespace.illumina.com/'
    api_version     = 'v1pre3'
    
    bs_api = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id, access_token)
    
    # Now we'll do some work of our own. First get a project to work on
    # we'll need write permission, for the project we are working on
    # meaning we will need get a new token and instantiate a new BaseSpaceAPI
    
    device_info = bs_api.get_verification_code('browse global')
    link = device_info['verification_with_code_uri']
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
    
    code = device_info['device_code']
    bs_api.update_privileges(code)
    
    prj = bs_api.get_project_by_id('183184')

Assuming we have write access for the project, we will list the current analyses for the project:

    statuses = ['Running']
    app_res = prj.get_app_results(bs_api, {}, statuses)
    puts "The current running AppResults are #{app_res}"
    puts

The output will be:

    The current running AppResults are [BWA GATK - HiSeq 2500 NA12878 demo 2x150, HiSeq 2500 NA12878 demo 2x150 App Result]

To create an appResults for a project, simply give the name and description:

    app_session_id = ''
    app_results = prj.create_app_result(bs_api, "testing", "this is my results", app_session_id) # need to verify example 4 code.
    puts "Some info about our new app results"
    puts app_results
    puts app_results.id
    puts
    puts "The app results also comes with a reference to our AppSession"
    my_app_session = app_results.app_session
    puts my_app_session
    puts

The output will be:

    Some info about our new app results
    AppResult: testing
    153153
    
    The app results also comes with a reference to our AppSession
    App session by 152152: <my name> - Id: <my appSession Id> - status: Running

We can change the status of our AppSession and add a status-summary as follows

    my_app_session.set_status(bs_api, 'needsattention', "We worked hard, but encountered some trouble.")
    puts "After a change of status of the app sessions we get #{my_app_session}"
    puts
    # we'll set our appSession back to running so we can do some more work.
    my_app_session.set_status(bs_api, 'running', "Back on track")

The output will be:

    After a change of status of the app sessions we get
    App session by 152152: <my name> - Id: <my appSession Id> - status: NeedsAttention

Now we will make another AppResult and try to upload a file to it

    app_results2 = prj.create_app_result(bs_api, "My second AppResult", "This one I will upload to")
    app_results2.upload_file(bs_api, '/tmp/testFile2.txt', 'BaseSpaceTestFile.txt', '/mydir/', 'text/plain')
    puts "My AppResult number 2 #{app_results2}"
    puts
    
    # Let's see if our new file made it.
    app_result_files = app_results2.get_files(bs_api)
    puts "These are the files in the appResult"
    puts app_result_files
    f = app_result_files.last

The output will be:

    My AppResult number 2 
    AppResult: My second AppResult
    
    These are the files in the appResult
    [BaseSpaceTestFile.txt]

We can even download our newly uploaded file in the following manner:

    f = bs_api.get_file_by_id(f.id)
    f.download_file(bs_api, '/tmp/')

## Cookbook

This section contains useful code snippets, which are demonstrating frequent use-cases in App development.

### Filtering File-Lists and AppResult-Lists using Query Parameter Dictionaries

Given a sample "a\_sample" we can retrieve a subset of the full file-list using a query parameter dictionary:

    # Get a BaseSpace API object as above, retrieve a list of our projects,
    # pick the first available project, get its samples, and then assign the
    # first sample to `a_sample`.
    bs_api = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id, access_token)
    my_projects = bs_api.get_project_by_user('current')
    a_project = my_projects.first
    my_samples = a_project.get_samples(bs_api)
    
    # Get a brief sample representation from the point of a project:
    a_sample = my_samples.first
    
    # Get the full version via direct BaseSpace API call (for demonstration, not required below):
    full_sample = bs_api.get_sample_by_id(a_sample.get_attr('Id'))
    
    # Get a list of files associated with the sample:
    # Possible output: ["s_G1_L001_I1_001.fastq.1.gz - id: '535642', size: '7493990'", "s_G1_L001_I1_002.fastq.1.gz - id: '535643', size: '7525743'"]
    a_sample.get_files(bs_api).map { |file| file.to_s }
    
    # Get a listing of ".gz" files:
    a_sample.get_files(bs_api, { 'Extensions' => 'gz' })
    
    # Get a listing with multiple extension filter (".bam" and ".vcf" files):
    a_sample.get_files(bs_api, { 'Extensions' => 'bam,vcf' })

You can provide all other legal sorting/filtering keyword in this dictionary to get further refinement of the list:

    a_sample.get_files(bs_api, { 'Extensions' => 'bam,vcf', 'SortBy' => 'Path', 'Limit' => 1 })

You can supply a dictionary of query parameters when you retrieving `AppResult`s, in the same way you filter file lists. Below is an example of how to limit the number of results from 100 (default value for "Limit") to 10.

    results = a_project.get_app_results(bs_api)
    
    # Possible output: 100
    results.length
    
    # Restrict the returned list of results to 10 items.
    # New length of `results`: 10
    results = a_project.get_app_results(bs_api, { 'Limit' => '10' })
    results.length

## Feature Requests and Bugs

Please feel free to report any feedback regarding the BaseSpace Ruby SDK directly to the [GitHub repository](https://github.com/joejimbo/basespace-ruby-sdk). We appreciate any and all feedback about the SDKs and we will do anything we can to improve the functionality and quality of the SDK to make it easy for developers to use. 

# SDK Development Manual

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

# Authors

Joachim Baran, Raoul Bonnal, Eri Kibukawa, Francesco Strozzi, Toshiaki Katayama

# Copying / License

See [License.txt](https://raw.github.com/joejimbo/basespace-ruby-sdk/master/License.txt) for details on licensing and distribution.


