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

require 'basespace/api/api_client'
require 'basespace/api/base_api'
require 'basespace/api/basespace_error'
require 'basespace/model/query_parameters'

require 'net/https'
require 'uri'
require 'json'

Net::HTTP.version_1_2


module Bio
module BaseSpace

# The main API class used for all communication with the REST server
class BaseSpaceAPI < BaseAPI

  # Uris for obtaining a access token, user verification code, and app trigger information
  TOKEN_URL      = '/oauthv2/token'
  DEVICE_URL     = "/oauthv2/deviceauthorization"
  WEB_AUTHORIZE  = '/oauth/authorize'

  def initialize(client_key, client_secret, api_server, version, app_session_id = nil, access_token = nil)
    end_with_slash = %r(/$)
    unless api_server[end_with_slash]
      api_server += '/'
    end
    #unless version[end_with_slash]
    #  version += '/'
    #end
    
    @app_session_id  = app_session_id
    @key             = client_key
    @secret          = client_secret
    @api_server      = api_server + version
    @version         = version
    @weburl          = api_server.sub('api.', '')
    @timeout         = nil

    super(access_token)
  end

  # Warning this method is not for general use and should only be called from the get_app_session.
  #
  # :param obj: The appTrigger json 
  def get_trigger_object(obj)
    if obj['ResponseStatus'].has_key?('ErrorCode')
      raise 'BaseSpace error: ' + obj['ResponseStatus']['ErrorCode'].to_s + ": " + obj['ResponseStatus']['Message']
    end
    #access_token = nil  # '' is false in Python but APIClient.new only raises when the value is None (not '')
    access_token = ''
    temp_api = APIClient.new(access_token, @api_server)
    response = temp_api.deserialize(obj, 'AppSessionResponse')
    # AppSessionResponse object has a response method which returns a AppSession object
    app_sess = response.get_attr('Response')
    # AppSession object has a serialize_references method which converts an array of
    # AppSessionLaunchObject objects by calling serialize_object method in each object.
    # The method in turn calls the serialize_object method of the given BaseSpaceAPI object
    # with @content ('dict') and @type ('str') arguments. Returns an array of serialized objects.
    res = app_sess.serialize_references(self)
    return res
  end
  
  def serialize_object(d, type)
    # [TODO] None (nil) or '' ?
    #access_token = nil
    access_token = ''
    temp_api = APIClient.new(access_token, @api_server)
    if type.downcase == 'project'
      return temp_api.deserialize(d, 'Project')
    end
    if type.downcase == 'sample'
      return temp_api.deserialize(d, 'Sample')
    end
    if type.downcase == 'appresult'
      return temp_api.deserialize(d, 'AppResult')
    end
    return d
  end


  # Returns the appSession identified by id
  #
  # :param id: The id of the appSession
  def get_app_session_by_id(id)
    # TO_DO make special case for access-token only retrieval
    return get_app_session(id)
  end

  # Returns an AppSession instance containing user and data-type the app was triggered by/on
  #
  # :param id: (Optional) The AppSessionId, id not supplied the AppSessionId used for instantiating the BaseSpaceAPI instance.
  def get_app_session(id = nil)
    if (not @app_session_id) and (not id)
      raise "This BaseSpaceAPI instance has no app_session_id set and no alternative id was supplied for method get_app_session"
    end

    # if (not id) and (not @key)
    #   raise "This BaseSpaceAPI instance has no client_secret (key) set and no alternative id was supplied for method get_app_session"
    # end
    
    resource_path = @api_server + '/appsessions/{AppSessionId}'
    unless id
      resource_path = resource_path.sub('{AppSessionId}', @app_session_id)
    else
      resource_path = resource_path.sub('{AppSessionId}', id)
    end
    if $DEBUG
      $stderr.puts "    # ----- BaseSpaceAPI#get_app_session ----- "
      $stderr.puts "    # resource_path: #{resource_path}"
      $stderr.puts "    # "
    end
    uri = URI.parse(resource_path)
    uri.user = @key
    uri.password = @secret
    #response = Net::HTTP.get(uri)
    http_opts = {}
    if uri.scheme == "https"
      http_opts[:use_ssl] = true
    end
    response = Net::HTTP.start(uri.host, uri.port, http_opts) { |http|
      request = Net::HTTP::Get.new(uri.path)
      request.basic_auth uri.user, uri.password
      http.request(request)
    }
    obj = JSON.parse(response.body)
    # TODO add exception if response isn't OK, e.g. incorrect server gives path not recognized
    return get_trigger_object(obj)
  end

  # :param obj: The data object we wish to get access to
  # :param access_type: (Optional) the type of access (read|write), default is write
  # :param web: (Optional) true if the App is web-based, default is false meaning a device based app
  # :param redirect_url: (Optional) For the web-based case, a
  # :param state: (Optional)
  def get_access(obj, access_type = 'write', web = nil, redirect_url = nil, state = nil)
    scope_str = obj.get_access_str(access_type)
    if web
      return get_web_verification_code(scope_str, redirect_url, state)
    else
      return get_verification_code(scope_str)
    end
  end
      
  # Returns the BaseSpace dictionary containing the verification code and verification url for the user to approve
  # access to a specific data scope.  
  # 
  # Corresponding curl call:
  # curlCall = 'curl -d "response_type=device_code" -d "client_id=' + client_key + '" -d "scope=' + scope + '" ' + DEVICE_URL
  # 
  # For details see:
  # https://developer.basespace.illumina.com/docs/content/documentation/authentication/obtaining-access-tokens
  # 
  # :param scope: The scope that access is requested for
  def get_verification_code(scope)
    #curlCall = 'curl -d "response_type=device_code" -d "client_id=' + @key + '" -d "scope=' + scope + '" ' + @api_server + DEVICE_URL
    #puts curlCall
    unless @key
      raise "This BaseSpaceAPI instance has no client_secret (key) set and no alternative id was supplied for method get_verification_code"
    end
    data = {'client_id' => @key, 'scope' => scope, 'response_type' => 'device_code'}
    return make_curl_request(data, @api_server + DEVICE_URL)
  end

  # Generates the URL the user should be redirected to for web-based authentication
  #  
  # :param scope: The scope that access is requested for
  # :param redirect_url: The redirect URL
  # :state: An optional state parameter that will passed through to the redirect response
  def get_web_verification_code(scope, redirect_url, state = nil)
    if (not @key)
      raise "This BaseSpaceAPI instance has no client_id (key) set and no alternative id was supplied for method get_verification_code"
    end
    data = {'client_id' => @key, 'redirect_uri' => redirect_url, 'scope' => scope, 'response_type' => 'code', "state" => state}
    return @weburl + WEB_AUTHORIZE + '?' + hash2urlencode(data)
  end

  # Returns a user specific access token.    
  # :param device_code: The device code returned by the verification code method
  def obtain_access_token(device_code)
    if (not @key) or (not @secret)
      raise "This BaseSpaceAPI instance has either no client_secret or no client_id set and no alternative id was supplied for method get_verification_code"
    end
    data = {'client_id' => @key, 'client_secret' => @secret, 'code' => device_code, 'grant_type' => 'device', 'redirect_uri' => 'google.com'}
    # [TODO] confirm dict is a Hash in Ruby
    dict = make_curl_request(data, @api_server + TOKEN_URL)
    return dict['access_token']
  end

  def update_privileges(code)
    token = obtain_access_token(code)
    set_access_token(token)
  end
          

  # Creates a project with the specified name and returns a project object. 
  # If a project with this name already exists, the existing project is returned.
  #
  # :param name: Name of the project
  def create_project(name)
    #: v1pre3/projects, it requires 1 input parameter which is Name
    my_model       = 'ProjectResponse'
    resource_path  = '/projects/'
    resource_path  = resource_path.sub('{format}', 'json')
    method         = 'POST'
    query_params   = {}
    header_params  = {}
    post_data      = {}
    post_data['Name']  = name
    verbose        = false
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end
          
  # Returns the User object corresponding to Id
  #
  # :param id: The Id of the user
  def get_user_by_id(id)
    my_model       = 'UserResponse'
    resource_path  = '/users/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    return single_request(my_model, resource_path, method, query_params, header_params)
  end
         
  # Returns an AppResult object corresponding to Id
  #
  # :param id: The Id of the AppResult
  def get_app_result_by_id(id)
    my_model       = 'AppResultResponse'
    resource_path  = '/appresults/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    return single_request(my_model, resource_path, method, query_params, header_params)
  end

  # Returns a list of File object for the AppResult with id  = Id
  # 
  # :param id: The id of the appresult.
  # :param query_pars: An (optional) object of type QueryParameters for custom sorting and filtering 
  def get_app_result_files(id, qp = {})
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'File'
    resource_path  = '/appresults/{Id}/files'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    verbose        = false
    return list_request(my_model, resource_path, method, query_params, header_params, verbose)
  end

  # Request a project object by Id
  # 
  # :param id: The Id of the project
  def get_project_by_id(id)
    my_model       = 'ProjectResponse'
    resource_path  = '/projects/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    return single_request(my_model, resource_path, method, query_params, header_params)
  end
         
  # Returns a list available projects for a User with the specified Id
  # 
  # :param id: The id of the user
  # :param qp: An (optional) object of type QueryParameters for custom sorting and filtering
  def get_project_by_user(id, qp = {})
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'Project'
    resource_path  = '/users/{Id}/projects'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id) if id != nil
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    return list_request(my_model, resource_path, method, query_params, header_params)
  end
     
  # Returns a list of accessible runs for the User with id=Id
  # 
  # :param id: An user id
  # :param query_pars: An (optional) object of type QueryParameters for custom sorting and filtering
  def get_accessible_runs_by_user(id, qp = {})
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'RunCompact'
    resource_path  = '/users/{Id}/runs'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    return list_request(my_model, resource_path, method, query_params, header_params)
  end
  
  # Returns a list of AppResult object associated with the project with Id
  # 
  # :param id: The project id
  # :param query_pars: An (optional) object of type QueryParameters for custom sorting and filtering
  # :param statuses: An (optional) list of AppResult statuses to filter by
  def get_app_results_by_project(id, qp = {}, statuses = [])
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'AppResult'
    resource_path  = '/projects/{Id}/appresults'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    unless statuses.empty?
      query_params['Statuses'] = statuses.join(",")
    end
    header_params  = {}
    verbose        = false
    return list_request(my_model, resource_path, method, query_params, header_params, verbose)
  end

  # Returns a list of samples associated with a project with Id
  # 
  # :param id: The id of the project
  # :param query_pars: An (optional) object of type QueryParameters for custom sorting and filtering
  def get_samples_by_project(id, qp = {})
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'Sample'
    resource_path  = '/projects/{Id}/samples'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    verbose        = false
    return list_request(my_model, resource_path, method, query_params, header_params, verbose)
  end

  # Returns a Sample object
  # 
  # :param id: The id of the sample
  def get_sample_by_id(id)
    my_model       = 'SampleResponse'
    resource_path  = '/samples/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    post_data      = nil
    verbose        = false
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end

  # Returns a list of File objects associated with sample with Id
  # 
  # :param id: A Sample id
  # :param query_pars: An (optional) object of type QueryParameters for custom sorting and filtering
  def get_files_by_sample(id, qp = {})
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'File'
    resource_path  = '/samples/{Id}/files'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    verbose        = false
    return list_request(my_model, resource_path, method, query_params, header_params, verbose)
  end
  
  # Returns a file object by Id
  # 
  # :param id: The id of the file
  def get_file_by_id(id)
    my_model       = 'FileResponse'
    resource_path  = '/files/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    post_data      = nil
    verbose        = false
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end

  # Returns an instance of Genome with the specified Id
  # 
  # :param id: The genome id
  def get_genome_by_id(id)
    my_model       = 'GenomeResponse'
    resource_path  = '/genomes/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    return single_request(my_model, resource_path, method, query_params, header_params)
  end

  # Returns a list of all available genomes
  # 
  # :param query_pars: An (optional) object of type QueryParameters for custom sorting and filtering
  def get_available_genomes(qp = {})
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'GenomeV1'
    resource_path  = '/genomes'
    resource_path  = resource_path.sub('{format}', 'json')
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    verbose        = false
    return list_request(my_model, resource_path, method, query_params, header_params, verbose)
  end
  
  # TODO, needs more work in parsing meta data, currently only map keys are returned 
  
  # Returns a VariantMetadata object for the variant file
  # 
  # :param id: The Id of the VCF file
  # :param format: Set to 'vcf' to get the results as lines in VCF format
  def get_variant_metadata(id, format)
    my_model       = 'VariantsHeaderResponse'
    resource_path  = '/variantset/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    query_params['Format'] = @api_client.to_path_value(format)
    header_params  = {}
    verbose        = false
    return single_request(my_model, resource_path, method, query_params, header_params, verbose)
  end
  
  # List the variants in a set of variants. Maximum returned records is 1000
  # 
  # :param id: The id of the variant file 
  # :param chrom: The chromosome of interest
  # :param start_pos: The start position of the sequence of interest
  # :param end_pos: The start position of the sequence of interest
  # :param format: Set to 'vcf' to get the results as lines in VCF format
  # :param query_pars: An (optional) object of type QueryParameters for custom sorting and filtering
  def filter_variant_set(id, chrom, start_pos, end_pos, format, qp = {'SortBy' => 'Position'})
    query_pars     = QueryParameters.new(qp)
    query_pars.validate
    my_model       = 'Variant'
    resource_path  = '/variantset/{Id}/variants/chr{Chrom}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Chrom}', chrom)
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = query_pars.get_parameter_dict
    header_params  = {}
    query_params['StartPos']  = start_pos
    query_params['EndPos']    = end_pos
    query_params['Format']    = format
    verbose        = false
    return list_request(my_model, resource_path, method, query_params, header_params, verbose)
  end
  
  # Mean coverage levels over a sequence interval
  # 
  # :param id: Chromosome to query
  # :param chrom: The Id of the resource
  # :param start_pos: Get coverage starting at this position. Default is 1
  # :param end_pos: Get coverage up to and including this position. Default is start_pos + 1280
  # 
  # :return:CoverageResponse -- an instance of CoverageResponse
  def get_interval_coverage(id, chrom, start_pos = nil, end_pos = nil)
    my_model       = 'CoverageResponse'
    resource_path  = '/coverage/{Id}/{Chrom}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Chrom}', chrom)
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    query_params['StartPos']  = @api_client.to_path_value(start_pos)
    query_params['EndPos']    = @api_client.to_path_value(end_pos)
    post_data      = nil
    verbose        = false
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end

  # Returns Metadata about coverage as a CoverageMetadata instance
  # 
  # :param id: he Id of the Bam file 
  # :param chrom: Chromosome to query
  def get_coverage_meta_info(id, chrom)
    my_model       = 'CoverageMetaResponse'
    resource_path  = '/coverage/{Id}/{Chrom}/meta'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Chrom}', chrom)
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}
    post_data      = nil
    verbose        = false
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end
   
  # Create an AppResult object
  # 
  # :param id: The id of the project in which the AppResult is to be added
  # :param name: The name of the AppResult
  # :param desc: A describtion of the AppResult
  # :param samples: (Optional) The samples 
  # :param app_session_id: (Optional) If no app_session_id is given, the id used to initialize the BaseSpaceAPI instance will be used. If app_session_id is set equal to an empty string, a new appsession will be created for the 
  def create_app_result(id, name, desc, samples = [], app_session_id = nil)
    if (not @app_session_id) and (not app_session_id)
      raise "This BaseSpaceAPI instance has no app_session_id set and no alternative id was supplied for method create_app_result"
    end
    
    my_model       = 'AppResultResponse'
    resource_path  = '/projects/{ProjectId}/appresults'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{ProjectId}', id)
    method         = 'POST'
    query_params   = {}
    header_params  = {}
    post_data      = {}
    verbose        = false
    
    if app_session_id
      query_params['appsessionid']  = app_session_id
    else
      query_params['appsessionid']  = @app_session_id      # default case, we use the current appsession
    end
    
    # add the sample references
    if samples.length > 0
      ref = []
      samples.each do |s|
        d = { "Rel" => "using", "Type" => "Sample", "HrefContent" => @version + '/samples/' + s.id }
        ref << d
      end
      post_data['References']  = ref
    end

    # case, an appSession is provided, we need to check if the a
    if query_params.has_key?('appsessionid')
      sid = query_params['appsessionid']
      session = get_app_session(sid)
      unless session.can_work_on
        raise 'AppSession status must be "running," to create and AppResults. Current status is ' + session.status
      end
    end
        
    post_data['Name']         = name
    post_data['Description']  = desc
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end
          
  # Uploads a file associated with an AppResult to BaseSpace and returns the corresponding file object  
  # 
  # :param id: AppResult id.
  # :param local_path: The local path to the file to be uploaded.
  # :param file_name: The desired filename in the AppResult folder on the BaseSpace server.
  # :param directory: The directory the file should be placed in.
  # :param content_type: The content-type of the file.
  def app_result_file_upload(id, local_path, file_name, directory, content_type, multipart = 0)
    my_model       = 'FileResponse'
    resource_path  = '/appresults/{Id}/files'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'POST'
    query_params   = {}
    header_params  = {}
    verbose        = false

    query_params['name']           = file_name
    query_params['directory']      = directory 
    header_params['Content-Type']  = content_type

    # three cases, two for multipart, starting 
    if multipart == 1
      query_params['multipart']  = 'true'
      post_data    = nil
      force_post   = true
      # Set force post as this need to use POST though no data is being streamed
      return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose, force_post)
    elsif multipart == 2
      query_params = {'uploadstatus' => 'complete'}
      post_data    = nil
      force_post   = true
      # Set force post as this need to use POST though no data is being streamed
      return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose, force_post)
    else
      post_data = File.open(local_path).read
      return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
    end
  end

  # Downloads a BaseSpace file to a local directory
  # 
  # :param id: The file id
  # :param local_dir: The local directory to place the file in
  # :param name: The name of the local file
  # :param range: (Optional) The byte range of the file to retrieve (not yet implemented)
  def file_download(id, local_dir, name, range = [])  #@ReservedAssignment
    resource_path  = '/files/{Id}/content'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'GET'
    query_params   = {}
    header_params  = {}

    query_params['redirect'] = 'meta' # we need to add this parameter to get the Amazon link directly 
    
    response = @api_client.call_api(resource_path, method, query_params, nil, header_params)
    if response['ResponseStatus'].has_key?('ErrorCode')
      raise 'BaseSpace error: ' + response['ResponseStatus']['ErrorCode'].to_s + ": " + response['ResponseStatus']['Message']
    end
    
    # get the Amazon URL 
    file_url = response['Response']['HrefContent']

    header = nil
    unless range.empty?
      # puts "Case range request" 
      header = { 'Range' => format('bytes=%s-%s', range[0], range[1]) }
    end
    
    # Do the download
    File.open(File.join(local_dir, name), "wb") do |fp|
      http_opts = {}
      if uri.scheme == "https"
        http_opts[:use_ssl] = true
      end
      uri = URI.parse(file_url)
      res = Net::HTTP.start(uri.host, uri.port, http_opts) { |http|
        # [TODO] Do we need user and pass here also?
        http.get(uri.path, header)
      }
      fp.print res.body
    end

    return 1
  end

  # Helper method, do not call
  # 
  # :param id: file id 
  # :param part_number: the file part to be uploaded
  # :param md5: md5 sum of datastream
  # :param data: the data-stream to be uploaded
  def upload_multipart_unit(id, part_number, md5, data)
    resource_path  = '/files/{Id}/parts/{partNumber}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    resource_path  = resource_path.sub('{partNumber}', part_number.to_s)
    method         = 'PUT'
    query_params   = {}
    header_params  = {'Content-MD5' => md5.strip()}
    force_post     = false
    out = @api_client.call_api(resource_path, method, query_params, data, header_params, force_post)
    return out
    # curl -v -H "x-access-token: {access token}" \
    #   -H "Content-MD5: 9mvo6qaA+FL1sbsIn1tnTg==" \
    #   -T reportarchive.zipaa \
    #   -X PUT https://api.cloud-endor.illumina.com/v1pre2/files/7094087/parts/1
  end

  # Not yet implemented (by Illumina Python SDK)
  #
  # def large_file_download
  #   raise 'Not yet implemented'
  # end
  
  # Method for multi-threaded file-upload for parallel transfer of very large files (currently only runs on unix systems)
  # 
  # 
  # :param id: The AppResult ID
  # :param local_path: The local path of the file to be uploaded
  # :param file_name: The desired filename on the server
  # :param directory: The server directory to place the file in (empty string will place it in the root directory)
  # :param content_type: The content type of the file
  # :param tempdir: Temp directory to use, if blank the directory for 'local_path' will be used
  # :param cpuCount: The number of CPUs to be used
  # :param partSize: The size of individual upload parts (must be between 5 and 25mb)
  # :param verbose: Write process output to stdout as upload progresses
  #
  # def multipart_file_upload(self, id, local_path, file_name, directory, content_type, tempdir = nil, cpuCount = 2, partSize = 25, verbose = false)
  #   # Create file object on server
  #   multipart = 1
  #   my_file = app_result_file_upload(id, local_path, file_name, directory, content_type, multipart)
  #
  #   # prepare multi-par upload objects
  #   my_mpu = mpu(self, id, local_path, my_file, cpu_count, part_size, tempdir, verbose)
  #   return my_mpu
  # end
  #
  # def mark_file_state(id)
  # end

  # Set the status of an AppResult object
  # 
  # :param id: The id of the AppResult
  # :param status: The status assignment string must
  # :param summary: The summary string
  def set_app_session_state(id, status, summary)
    my_model       = 'AppSessionResponse'
    resource_path  = '/appsessions/{Id}'
    resource_path  = resource_path.sub('{format}', 'json')
    resource_path  = resource_path.sub('{Id}', id)
    method         = 'POST'
    query_params   = {}
    header_params  = {}
    post_data      = {}
    verbose        = false

    status_allowed = ['running', 'complete', 'needsattention', 'aborted', 'error']
    unless status_allowed.include?(status.downcase)
      raise "AppResult state must be in #{status_allowed.inspect}"
    end
    post_data['status']         = status.downcase
    post_data['statussummary']  = summary
    return single_request(my_model, resource_path, method, query_params, header_params, post_data, verbose)
  end
end

end # module BaseSpace
end # module Bio

