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

require 'basespace/api/basespace_error'
require 'basespace/model'
require 'basespace/model/query_parameters'

module Bio
module BaseSpace

# Contains the files that are output by an App.
#
# App results are usually BAM or VCF files, even though other file types
# may also be provided.
class AppResult < Model

  # Create a new AppResult instance.
  def initialize
    @swagger_types = {
      'Name'           => 'str',
      #'Status'        => 'str',        # will be deprecated
      'Description'    => 'str',
      'StatusSummary'  => 'str',
      'HrefFiles'      => 'str',
      'DateCreated'    => 'datetime',
      'Id'             => 'str',
      'Href'           => 'str',
      'UserOwnedBy'    => 'UserCompact',
      'StatusDetail'   => 'str',
      'HrefGenome'     => 'str',
      'AppSession'     => 'AppSession',
      'References'     => 'dict',
    }
    @attributes = {
      'Name'           => nil,
      'Description'    => nil,
      'StatusSummary'  => nil,
      'HrefFiles'      => nil,
      'DateCreated'    => nil,
      'Id'             => nil,
      'Href'           => nil,
      'UserOwnedBy'    => nil, # UserCompact
      'StatusDetail'   => nil,
      'HrefGenome'     => nil,
      'AppSession'     => nil, # AppSession
      'References'     => nil,
    }
  end

  # Return the name of the AppResult.
  def to_s
    # NOTE Simplified in Ruby to align with the Sample class.
    #      See example 3_accessing_files.rb (3_AccessingFiles.py)
    #return "AppResult: #{get_attr('Name')}" #+ " - #{get_attr('Status')"
    return get_attr('Name')
  end

  # Returns the scope-string to be used for requesting BaseSpace access to the object.
  #
  # +scope+:: The scope-type that is request (write|read).
  def get_access_str(scope = 'write')
    is_init
    return "#{scope} appresult #{get_attr('Id')}"
  end

  # Tests if the Project instance has been initialized.
  #
  # Throws ModelNotInitializedError, if the instance has not been populated.
  def is_init
    raise ModelNotInitializedError.new('The AppResult model has not been initialized yet') unless get_attr('Id')
  end

  # Return a list of sample IDs for the samples referenced.
  def get_referenced_samples_ids
    res= []
    get_attr('References').each do |s|
      # [TODO] check this Hash contains the key :type (or should we use 'Type'?)
      if s[:type] == 'Sample'
        id = s[:href_content].split('/').last
        res << id
      end
    end
    return res
  end

  # Returns a list of sample objects references by the AppResult.
  #
  # NOTE This method makes one request to REST server per sample.
  #
  # +api+:: BaseSpaceAPI instance.
  def get_referenced_samples(api)
    res = []
    ids = get_referenced_samples_ids
    ids.each do |id|
      begin
        sample = api.get_sample_by_id(id)
        res << sample
      rescue => err
        # [TODO] What to do with this 'err'?
        $stderr.puts "    # ----- AppResult#get_referenced_samples ----- "
        $stderr.puts "    # Error: #{err}"
        $stderr.puts "    # "
      end
    end
    return res
  end

  # Returns a list of file objects in the result set.
  #
  # +api+:: BaseSpaceAPI instance.
  # +my_qp+:: QueryParameters for sorting and filtering the file list.
  def get_files(api, my_qp = {})
    is_init
    query_pars = QueryParameters.new(my_qp)
    return api.get_app_result_files(get_attr('Id'), query_pars)
  end

  # Uploads a local file to the BaseSpace AppResult.
  #
  # +api+:: BaseSpaceAPI instance.
  # +local_path+: Local path of the file.
  # +file_name+:: Filename.
  # +directory+: The remote directory that the file is uploaded to.
  # +param content_type+:: Content-type of the file.
  def upload_file(api, local_path, file_name, directory, content_type)
    is_init
    return api.app_result_file_upload(get_attr('Id'), local_path, file_name, directory, content_type)
  end

  # Upload a file in multi-part mode. Returns an object of type MultipartUpload used for managing the upload.
  # 
  # +api+:: BaseSpaceAPI instance.
  # +local_path+:: Local path of the file.
  # +file_name+ Filename.
  # +directory+:: The remote directory that the file is uploaded to.
  # +content_type+:: Content-type of the file.
  # +cpu_count+:: Number of CPUs to used for the upload.
  # +part_size+:: Size of each upload chunk.
  # def upload_multipart_file(api, local_path, file_name, directory, content_type,temp_dir = '', cpu_count = 1, part_size = 10, verbose = 0)
  #   is_init
  #   return api.multipart_file_upload(get_attr('Id'), local_path, file_name, directory, content_type, temp_dir, cpu_count, part_size, verbose)
  # end

end

end # module BaseSpace
end # module Bio

