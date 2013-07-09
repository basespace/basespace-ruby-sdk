# BaseSpace Ruby SDK

``Bio::BaseSpace`` is a Ruby based SDK to be used in the development of Apps and scripts for working with Illumina's BaseSpace cloud-computing solution for next-gen sequencing data analysis.

The primary purpose of the SDK is to provide an easy-to-use Ruby environment enabling developers to authenticate a user, retrieve data, and upload data/results from their own analysis to BaseSpace.


*Note:* It will be necessary to have created a BaseSpace account with a new App and have the ``client_key`` and ``client_secret`` codes for the App available to run a number of the following examples.

## Availability

Current version of ``Bio::BaseSpace`` can be checked out here:

	git clone https://github.com/joejimbo/basespace-ruby-sdk.git

or by,

	git clone git@github.com:joejimbo/basespace-ruby-sdk.git

## Setup

*Requirements:* Ruby 1.9.3 and above. The multi-part file upload will currently only run on a unix setup.

You can include 'Bio::BaseSpace' by setting below environmental variable: 

	export RUBYLIB=/path/to/basespace-ruby-sdk/lib/

or add it to your Ruby scripts using Bio::BaseSpace:

	$: << '/path/to/basespace-ruby-sdk/lib/'

To test that everything is working as expected, launch a Interactive Ruby and try importing 'Bio::BaseSpace': 


	$ irb
	>> require 'basespace'
	>> include Bio::BaseSpace


## Application triggering

This section demonstrates how to retrieve the ``AppSession`` object produced when a user triggers a BaseSpace App. 
Further, we cover how to automatically generate the scope strings to request access to the data object (be it a project or a sample) that the App was triggered to analyze.

The initial http request to our App from BaseSpace is identified by an ``ApplicationActionId``, using this piece of information 
we are able to obtain information about the user who launched the App and the data that is sought analyzed by the App. 
First, we instantiate a BaseSpaceAPI object using the ``client_key`` and ``client_secret`` codes provided on the BaseSpace developer's website when registering our App, as well as the ``AppSessionId`` generated from the app-triggering: 


	require 'basespace'
	
	include Bio::BaseSpace
	
	# initialize an authentication object using the key and secret from your app
	# Fill in with your own values
	
	client_id       = 'my client key'
	client_secret   = 'my client secret'
	app_session_id  = 'my app session id'
	basespace_url   = 'https://api.basespace.illumina.com/'
	api_version     = 'v1pre3'
	
	# First we will initialize a BaseSpace API object using our app information and the appSessionId
	bs_api = BaseSpaceAPI.new(client_id, client_secret, basespace_url, api_version, app_session_id)
	
	# Using the bmy_app_session.spaceApi we can request the appSession object corresponding to the AppSession id supplied
	my_app_session = bs_api.get_app_session
	puts my_app_session
	
	# An app session contains a referal to one or more appLaunchObjects which reference the data module
	# the user launched the app on. This can be a list of projects, samples, or a mixture of objects
	puts "Type of data the app was triggered on can be seen in 'references'"
	puts my_app_session.references.inspect   # .inspect is used to put surrounding [] 
	puts

The output will be:

	App session by 600602: Toshiaki Katayama - Id: <my app session id> - status: Complete
	Type of data the app was triggered on can be seen in 'references'
	[Project]

We can also get a handle to the user who started the AppSession and further information on the ``AppLaunchObject``:

	# We can also get a handle to the user who started the AppSession
	puts "We can get a handle for the user who triggered the app"
	puts my_app_session.user_created_by
	puts
	
	# Let's have a closer look at the appSessionLaunchObject
	my_reference = my_app_session.references.first
	
	puts "We can get out information such as the href to the launch object:"
	puts my_reference.href_content
	puts
	puts "and the specific type of that object:"
	puts my_reference.type
	puts


The output will be:

	We can get a handle for the user who triggered the app
	13039: Eri Kibukawa
	
	We can get out information such as the href to the launch object:
	v1pre3/projects/848850
	
	and the specific type of that object:
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

We can easily request write access to the reference object so our App can start contributing analysis 
by default we ask for write permission to and authentication for a device:

   	access_map = bs_api.get_access(my_reference_content, 'write')
	puts "We get the following access map"
	puts access_map

The output will be:

    	We get the following access map
	{"device_code"=>"<my device code>", "user_code"=>"<my user code>", "verification_uri"=>"https://basespace.illumina.com/oauth/device", "verification_with_code_uri"=>"https://basespace.illumina.com/oauth/device?code=<my user code>", "expires_in"=>1800, "interval"=>1}

Have the user visit the verification uri to grant us access

	puts "\nPlease visit the uri within 15 seconds and grant access"
	puts access_map['verification_with_code_uri']

The output will be:

	Please visit the uri within 15 seconds and grant access
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


For more details on access-requests and authentication and an example of the web-based case see example 1_authentication.rb

-----

## Requesting an access-token for data browsing

Here we demonstrate the basic BaseSpace authentication process. The work-flow outlined here is

1. Request of access to a specific data-scope 
2. User approval of access request 
3. Browsing data

*Note:* It will be useful if you are logged in to the BaseSpace web-site before launching this example to make the access grant procedure faster.

Again we will start out by initializing a ``BaseSpaceAPI`` object:

	from BaseSpacePy.api.BaseSpaceAPI import BaseSpaceAPI
	import time

	client_key                 = <my key>
	client_secret              = <my secret>
	AppSessionId		   = <my appSession id>

	BaseSpaceUrl               = 'https://api.basespace.illumina.com/'
	version                    = 'v1pre3'



First get verification code and uri for scope 'browse global'

	deviceInfo = BSapi.getVerificationCode('browse global')
	print "\n URL for user to visit and grant access: "
	print deviceInfo['verification_with_code_uri']


At this point the user must visit the verification uri to grant us access

	## PAUSE HERE
	# Have the user visit the verification uri to grant us access
	print "\nPlease visit the uri within 15 seconds and grant access"
	print deviceInfo['verification_with_code_uri']
	webbrowser.open_new(deviceInfo['verification_with_code_uri'])
	time.sleep(15)
	## PAUSE HERE


The output will be:


	Output[]:
	
	URL for user to visit and grant access: 
	https://basespace.illumina.com/oauth/device?code=<my code>

	Please visit the uri within 15 seconds and grant access
	https://basespace.illumina.com/oauth/device?code=<my code>


Once the user has granted us access to objects we requested, we can get the basespace access_token and start browsing simply by calling ``updatePriviliges`` on the baseSpaceApi instance.

	code = deviceInfo['device_code']
	BSapi.updatePrivileges(code)

As a reference the provided access-token can be obtained from the BaseSpaceApi object

	print "\nMy Access-token:"
	print BSapi.getAccessToken()

The output will be:

	Output[]:
	
	My Access-token:
	<my access-token>

At this point we can start using the ``BaseSpaceAPI`` instance to browse the available data for the current user, the details of this process is the subject of the next section. Here we will end with showing how the API object can be used to list all BaseSpace genome instances: 

	# We will get all available genomes with our new api! 
	allGenomes  = myAPI.getAvailableGenomes()
	print "\nGenomes \n" + str(allGenomes)

The output will be:

	Output[]:
		
	Genomes 
	[Arabidopsis thaliana, Bos Taurus, Escherichia coli, Homo sapiens, Mus musculus, Phix,\
	 Rhodobacter sphaeroides, Rattus norvegicus, Saccharomyces cerevisiae, Staphylococcus aureus, Bacillus Cereus]


## Browsing data with global browse access

This section demonstrates basic browsing of BaseSpace objects once an access-token for global browsing has been obtained. We will see how 
objects can be retrieved using either the ``BaseSpaceAPI`` class or by use of method calls on related object instances (for example once 
a ``user`` instance we can use it to retrieve all project belonging to that user).

First we will initialize a ``BaseSpaceAPI`` using our access-token for ``global browse``:



	from BaseSpacePy.api.BaseSpaceAPI import BaseSpaceAPI
	
	# REST server information and user access_token 
	server          = 'https://api.basespace.illumina.com/'
	version         = 'v1pre3'
	client_key                 = <my key>
	client_secret              = <my secret>
	AppSessionId		   = <my appSession id>
	accessToken                = "<my access token>"
	
	# First, create a client for making calls for this user session 
	myAPI   = BaseSpaceAPI(client_key, client_secret, BaseSpaceUrl, version, AppSessionId,AccessToken=accessToken)


First we will try to retrieve a genome object:

	# Now grab the genome with id=4
	myGenome    = myAPI.getGenomeById('4')

	print "\nThe Genome is " + str(myGenome)
	print "We can get more information from the genome object"
	print 'Id: ' + myGenome.Id
	print 'Href: ' + myGenome.Href
	print 'DisplayName: ' + myGenome.DisplayName

The output will be:


	Output[]:

	The Genome is Homo sapiens
	We can get more information from the genome object
	Id: 4
	Href: v1pre2/genomes/4
	DisplayName: Homo Sapiens - UCSC (hg19)


Using a comparable method we can get a list of all available genomes:

	# Get a list of all genomes
	allGenomes  = myAPI.getAvailableGenomes()
	print "\nGenomes \n" + str(allGenomes)


The output will be:

	Output[]:
	
	Genomes 
	[Arabidopsis thaliana, Bos Taurus, Escherichia coli, Homo sapiens, Mus musculus, Phix,\
	 Rhodobacter sphaeroides, Rattus norvegicus, Saccharomyces cerevisiae, Staphylococcus aureus, Bacillus Cereus]

Now, let us retrieve the ``User`` objects for the current user, and list all projects for this user:

	# Take a look at the current user
	user        = myAPI.getUserById('current')
	print "\nThe current user is \n" + str(user)
	
	# Now list the projects for this user
	myProjects   = myAPI.getProjectByUser('current')
	print "\nThe projects for this user are \n" + str(myProjects)

The output will be:

	Output[]:
	
	The current user is 
	152152: Morten Kallberg
	
	The projects for this user are 
	[HiSeq 2500, Bolt, YourProject, 2X151 Rhodobacter Resequencing, EColi resequencing]


We can also achieve this by making a call using the ``user`` instance. Notice that these calls take an instance of ``BaseSpaceAPI`` with apporpriate 
priviliges to complete the transaction as parameter, this true for all retrieval method calls made on data objects:



	myProjects2 = user.getProjects(myAPI)
	print "\nProjects retrieved from the user instance \n" + str(myProjects2)
	
	# List the runs available for the current user
	runs = user.getRuns(myAPI)
	print "\nThe runs for this user are \n" + str(runs)

The output will be:


	Output[]:
	
	Projects retrieved from the user instance 
	[HiSeq 2500, Bolt, YourProject, 2X151 Rhodobacter Resequencing, EColi resequencing]
	
	The runs for this user are 
	[2X151 Rhodobacter Resequencing, 2x26 Validation Human 4-Plex, EColi resequencing]


In the same manner we can get a list of accessible user runs:



	runs = user.getRuns(myAPI)
	print "\nRuns retrieved from user instance \n" + str(runs)

The output will be:

	Output[]:
	
	Runs retrieved from user instance 
	[2X151 Rhodobacter Resequencing, 2x26 Validation Human 4-Plex, EColi resequencing]

	
## Accessing file-trees and querying BAM or VCF files

In this section we demonstrate how to access samples and analysis from a projects and how to work with the available file data for such instances.
In addition, we take a look at some of the special queuring methods associated with BAM- and VCF-files. 

Again, start out by initializing a ``BaseSpaceAPI`` instance and retrieving all projects belonging to the current user:

	# First, create a client for making calls for this user session 
	myAPI           = BaseSpaceAPI(client_key, client_secret, BaseSpaceUrl, version, AppSessionId,AccessToken=accessToken)
	user        = myAPI.getUserById('current')
	myProjects   = myAPI.getProjectByUser('current')


Now we can list all the analyses and samples for these projects

	# Let's list all the AppResults and samples for these projects
	for singleProject in myProjects:
	    print "# " + str(singleProject)
	    appResults = singleProject.getAppResults(myAPI)
	    print "    The App results for project " + str(singleProject) + " are \n\t" + str(appResults)
	    samples = singleProject.getSamples(myAPI)
	    print "    The samples for project " + str(singleProject) + " are \n\t" + str(samples)

The output will be:


	Output[]:
	
	# HiSeq 2500
	    The App results  for project HiSeq 2500 are 
		[Resequencing - Completed]
	    The samples for project HiSeq 2500 are 
		[NA18507]
	# Bolt
	    The App results  for project Bolt are 
		[Amplicon - Completed, Amplicon - Completed, Amplicon ...
	    The samples for project Bolt are 
		[sample_1, sample_2, sample_3, ...

	......
	

We'll take a further look at the files belonging to the sample from the last project in the loop above:

	for s in samples:
	    print "Sample " + str(s)
	    ff = s.getFiles(myAPI)
	    print ff


The output will be:

	Output[]:
	
	Sample Ecoli
	[s_G1_L001_R1_001.fastq.1.gz, s_G1_L001_R1_002.fastq.1.gz, s_G1_L001_R2_001.fastq.1.gz, s_G1_L001_R2_002.fastq.1.gz]


Now, have a look at some of the methods calls specific to ``Bam`` and ``VCF`` files. First, we will get a ``Bam``-file and then retrieve the coverage information available for chromosome 2 between positions 1 and 20000: 



	# Now do some work with files 
	# we'll grab a BAM by id and get the coverage for an interval + accompanying meta-data 

	myBam = myAPI.getFileById('2150156')
	print myBam
	cov     = myBam.getIntervalCoverage(myAPI,'chr2','1','20000')
	print cov 
	covMeta = myBam.getCoverageMeta(myAPI,'chr2')
	print covMeta

The output will be:

	Output[]:
	
	sorted.bam
	Chrchr2: 1-20096: BucketSize=16
	CoverageMeta: max=20483 gran=128

For ``VCF``-files we can filter variant calls based on chromosome and location as well:

	# and a vcf file
	myVCF = myAPI.getFileById('2150158')

	# Get the variant meta info 
	varMeta = myVCF.getVariantMeta(myAPI)
	print varMeta
	var     = myVCF.filterVariant(myAPI,'2','1', '11000') 
	print var

The output will be:

	Output[]:
	
	VariantHeader: SampleCount=1
	[Variant - chr2: 10236 id=['.'], Variant - chr2: 10249 id=['.'], ....]


## Creating an AppResult and uploading files

In this section we will see how to create a new AppResults object, change the state of the related AppSession,
and upload result files to it as well as retrieve files from it. 

First, create a client for making calls for this user session:
 
	myBaseSpaceAPI   = BaseSpaceAPI(client_key, client_secret, BaseSpaceUrl, version, AppSessionId,AccessToken=accessToken)

	# Now we'll do some work of our own. First get a project to work on
	# we'll need write permission, for the project we are working on
	# meaning we will need get a new token and instantiate a new BaseSpaceAPI  
	p = myBaseSpaceAPI.getProjectById('89')

Assuming we have write access for the project, we will list the current analyses for the project:

	appRes = p.getAppResults(myBaseSpaceAPI,statuses=['Running'])
	print "\nThe current running AppResults are \n" + str(appRes)



The output will be:

	Output[]:
	
	The current running AppResults are 
	[Results for sample 123, Results for sample 124 ...]


To create an appResults for a project, simply give the name and description:

	appResults = p.createAppResult(myBaseSpaceAPI,"testing","this is my results",appSessionId='')
	print "\nSome info about our new app results"
	print appResults
	print appResults.Id
	print "\nThe app results also comes with a reference to our AppSession"
	myAppSession = appResults.AppSession
	print myAppSession

The output will be:

	Output[]:
	
	Some info about our new app results
	AppResult: testing
	153153

	The app results also comes with a reference to our AppSession
	App session by 152152: Morten Kallberg - Id: <my appSession Id> - status: Running

We can change the status of our AppSession and add a status-summary as follows

	myAppSession.setStatus(myBaseSpaceAPI,'needsattention',"We worked hard, but encountered some trouble.")
	print "\nAfter a change of status of the app sessions we get\n" + str(myAppSession)
	# we'll set our appSession back to running so we can do some more work
	myAppSession.setStatus(myBaseSpaceAPI,'running',"Back on track")

The output will be:

	Output[]:

	After a change of status of the app sessions we get
	App session by 152152: Morten Kallberg - Id: <my appSession Id> - status: NeedsAttention
	
Now we will make another AppResult and try to upload a file to it

	appResults2 = p.createAppResult(myBaseSpaceAPI,"My second AppResult","This one I will upload to")
	appResults2.uploadFile(myBaseSpaceAPI, '/home/mkallberg/Desktop/testFile2.txt', 'BaseSpaceTestFile.txt', '/mydir/', 'text/plain')
	print "\nMy AppResult number 2 \n" + str(appResults2)
	
	## let's see if our new file made it
	appResultFiles = appResults2.getFiles(myBaseSpaceAPI)
	print "\nThese are the files in the appResult"
	print appResultFiles
	f = appResultFiles[-1]

The output will be:

	Output[]:

	My AppResult number 2 
	AppResult: My second AppResult

	These are the files in the appResult
	[BaseSpaceTestFile.txt]

We can even download our newly uploaded file in the following manner:

	f = myBaseSpaceAPI.getFileById(f.Id)
	f.downloadFile(myBaseSpaceAPI,'/home/mkallberg/Desktop/')

## Cookbook

This section contains useful code-snippets demonstrating use-cases that frequently come up in App development.

### Filtering file-lists and AppResult-lists using query parameter dictionaries

Given a sample "a" we can retrieve a subset of the full file-list using a query parameter dictionary:

	In [10]: a.getFiles(myAPI)
	Out[10]: [sorted.bam, sorted.bam.bai, genome.vcf]

	In [11]: a.getFiles(myAPI,myQp={'Extensions':'bam'})
	Out[11]: [sorted.bam]

Filter with multiple extensions:

	In [12]: a.getFiles(myAPI,myQp={'Extensions':'bam,vcf'})
	Out[12]: [sorted.bam, genome.vcf]

You can provide all other legal sorting/filtering keyword in this dictionary to get further refinement of the list:

	In [13]: a.getFiles(myAPI,myQp={'Extensions':'bam,vcf','SortBy':'Path'})
	Out[13]: [genome.vcf, sorted.bam]


You can supply a dictionary of query parameters when you retrieving appresults, in the same way you filter file lists. Below is an example of how to limit the number of results from 100 (default value for “Limit”) to 10.

	In [3]: res = p.getAppResults(myBaseSpaceAPI)

	In [4]: len(res)
	Out[4]: 100

	In [5]: res = p.getAppResults(myBaseSpaceAPI,myQp={'Limit':'10'})

	In [6]: len(res)
	Out[6]: 10

## Feature Requests and Bugs

Please feel free to report any feedback regarding the Python SDK directly to the [Python SK Repository](https://github.com/basespace/basespace-python-sdk), we appreciate any and all feedback about the SDKs.  We will do anything we can to improve the SDK and make it easy for developers to use the SDK. 






