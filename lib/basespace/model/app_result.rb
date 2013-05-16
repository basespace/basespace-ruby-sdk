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

require 'basespace/api/basespace_error'
require 'basespace/model/query_parameters'

module Bio
module BaseSpace

class AppResult
  attr_reader :swagger_types
  attr_accessor :name, :description, :status_summary, :href_files, :date_created, :id, :href, :user_owned_by, :status_detail, :href_genome, :app_session, :references

  def initialize
    @swagger_types = {
      :name            => 'str',
      #:status         => 'str',        # will be deprecated
      :description     => 'str',
      :status_summary  => 'str',
      :href_files      => 'str',
      :date_created    => 'datetime',
      :id              => 'str',
      :href            => 'str',
      :user_owned_by   => 'UserCompact',
      :status_detail   => 'str',
      :href_genome     => 'str',
      :app_session     => 'AppSession',
      :references      => 'dict'
    }

    @name              = nil
    @description       = nil
    @status_summary    = nil
    @href_files        = nil
    @date_created      = nil
    @id                = nil
    @href              = nil
    @user_owned_by     = nil # UserCompact
    @status_detail     = nil
    @href_genome       = nil
    @app_session       = nil # AppSession
    @references        = nil
  end

  def to_s
    return "AppResult: #{@name}" #+ " - " + @status.to_s
  end

  def to_str
    return self.inspect
  end
    
  # Returns the scope-string to be used for requesting BaseSpace access to the object
  #
  # :param scope: The scope-type that is request (write|read)
  def get_access_str(scope = 'write')
    is_init
    return "#{scope} appresult #{@id}"
  end

  # Is called to test if the Project instance has been initialized
  #
  # Throws:
  #   ModelNotInitializedError - if the instance has not been populated.
  def is_init
    raise ModelNotInitializedError.new('The AppResult model has not been initialized yet') unless @id
  end

  # Return a list of sample ids for the samples referenced.
  def get_referenced_samples_ids
    res= []
    @references.each do |s|
      if s[:type] == 'Sample'
        id = s[:href_content].split('/').last
        res << id
      end
    end
    return res
  end

  # Returns a list of sample objects references by the AppResult. NOTE this method makes one request to REST server per sample    
  def get_referenced_samples(api)
    res = []
    ids = get_referenced_samples_ids
    ids.each do |id|
      begin
        sample = api.get_sample_by_id(id)
        res << sample
      rescue
        e = 1
      end
    end
    return res
  end

  # Returns a list of file objects
  #
  # :param api: An instance of BaseSpaceAPI
  # :param my_qp: (Optional) QueryParameters for sorting and filtering the file list 
  def get_files(api, my_qp = {})
    is_init
    query_pars = QueryParameters.new(my_qp)
    return api.get_app_result_files(@id, query_pars)
  end

  # Uploads a local file to the BaseSpace AppResult
  #
  # :param api: An instance of BaseSpaceAPI
  # :param local_path: The local path of the file
  # :param file_name: The filename
  # :param directory: The remote directory to upload to
  # :param content_type: The content-type of the file
  def upload_file(api, local_path, file_name, directory, content_type)
    is_init
    return api.app_result_file_upload(@id, local_path, file_name, directory, content_type)
  end

  # Upload a file in multi-part mode. Returns an object of type MultipartUpload used for managing the upload.
  # 
  # :param api:An instance of BaseSpaceAPI
  # :param local_path: The local path of the file
  # :param file_name: The filename
  # :param directory: The remote directory to upload to
  # :param content_type: The content-type of the file
  # :param cpu_count: The number of CPUs to used for the upload
  # :param part_size:
  # def upload_multipart_file(api, local_path, file_name, directory, content_type,temp_dir = '', cpu_count = 1, part_size = 10, verbose = 0)
  #   is_init
  #   return api.multipart_file_upload(@id, local_path, file_name, directory, content_type, temp_dir, cpu_count, part_size, verbose)
  # end

end

end # module BaseSpace
end # module Bio

