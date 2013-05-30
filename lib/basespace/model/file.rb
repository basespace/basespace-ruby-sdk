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
require 'basespace/model'

module Bio
module BaseSpace

# Represents a BaseSpace file object.
class File < Model
  def initialize
    @swagger_types = {
      'Name'          => 'str',
      'HrefCoverage'  => 'str',
      'HrefParts'     => 'str',
      'DateCreated'   => 'datetime',
      'UploadStatus'  => 'str',
      'Id'            => 'str',
      'Href'          => 'str',
      'HrefContent'   => 'str',
      'HrefVariants'  => 'str',
      'ContentType'   => 'str',
      'Path'          => 'str',
      'Size'          => 'int',
    }
    @attributes = {
      'Name'          => nil, # str
      # If set, provides the relative Uri to fetch the mean coverage statistics for data stored in the file
      'HrefCoverage'  => nil, # str
      # If set, provides the relative Uri to fetch a list of completed file parts for multi-part file uploads in progress
      'HrefParts'     => nil, # str
      'DateCreated'   => nil, # datetime
      'UploadStatus'  => nil, # str
      'Id'            => nil, # str
      'Href'          => nil, # str
      'HrefContent'   => nil, # str
      # If set, provides the relative Uri to fetch the variants stored in the file
      'HrefVariants'  => nil, # str
      'ContentType'   => nil, # str
      'Path'          => nil, # str
      'Size'          => nil, # int
    }
  end

  def to_s
    str = get_attr('Name')
    begin
      str += " - id: '#{get_attr('Id')}', size: '#{get_attr('Size')}'"
      str += ", status: '#{get_attr('UploadStatus')}'" if get_attr('UploadStatus')
    rescue => err
      # [TODO] What to do with this 'err'?
      $stderr.puts "    # ----- File#to_s ----- "
      $stderr.puts "    # Error: #{err}"
      $stderr.puts "    # "
    end
    return str
  end

  # Is called to test if the File instance has been initialized.
  # 
  # Throws:
  #     ModelNotInitializedError if the instance has not been populated yet.
  def is_init
    raise ModelNotInitializedError.new('The File model has not been initialized yet') unless get_attr('Id')
  end
        
  # Is called to test if the File instance is matches the filtype parameter 
  #       
  # :param filetype: The filetype for coverage or variant requests
  def is_valid_file_option(filetype)
    if filetype == 'bam'
      raise WrongFiletypeError.new(get_attr('Name')) unless get_attr('HrefCoverage')
    end
    if filetype == 'vcf'
      raise WrongFiletypeError.new(get_attr('Name')) unless get_attr('HrefVariants')
    end
  end                

  # Download the file object to the specified localDir or a byte range of the file, by specifying the 
  # start and stop byte in the range.
  # 
  # :param api: A BaseSpaceAPI with read access on the scope including the file object.
  # :param loadlDir: The local directory to place the file in.
  # :param range: Specify the start and stop byte of the file chunk that needs retrieved.
  def download_file(api, local_dir, range = [])
    if range.empty?
      return api.file_download(get_attr('Id'),local_dir, get_attr('Name'))
    else
      return api.file_download(get_attr('Id'),local_dir, get_attr('Name'), range)
    end
  end

  def delete_file(api)
    raise 'Not yet implemented'
  end

  # Return a coverage object for the specified region and chromosome.
  # 
  # :param api: An instance of BaseSpaceAPI
  # :param Chrom: Chromosome as a string - for example 'chr2'
  # :param StartPos: The start position of region of interest as a string
  # :param EndPos: The end position of region of interest as a string
  def get_interval_coverage(api, chrom, start_pos, end_pos)
    is_init
    is_valid_file_option('bam')
    set_attr('Id', get_attr('HrefCoverage').split('/').last)
    return api.get_interval_coverage(get_attr('Id'), chrom, start_pos, end_pos)
  end
    
  # Returns a list of Variant objects available in the specified region
  # 
  # :param api: An instance of BaseSpaceAPI
  # :param Chrom: Chromosome as a string - for example 'chr2'
  # :param StartPos: The start position of region of interest as a string
  # :param EndPos: The end position of region of interest as a string
  # :param q: An instance of 
  #
  # TODO allow to pass a queryParameters object for custom filtering
  def filter_variant(api, chrom, start_pos, end_pos, q = nil)
    is_init
    is_valid_file_option('vcf')
    set_attr('Id', get_attr('HrefVariants').split('/').last)
    return api.filter_variant_set(get_attr('Id'), chrom, start_pos, end_pos, 'txt')
  end

  # Return an object of CoverageMetadata for the selected region
  # 
  # :param api: An instance of BaseSpaceAPI.
  # :param Chrom: The chromosome of interest.
  def get_coverage_meta(api, chrom)
    is_init
    is_valid_file_option('bam')
    set_attr('Id', get_attr('HrefCoverage').split('/').last)
    return api.get_coverage_meta_info(get_attr('Id'), chrom)
  end

  # Return the the meta info for a VCF file as a VariantInfo object
  # 
  # :param api: An instance of BaseSpaceAPI
  def get_variant_meta(api)
    is_init
    is_valid_file_option('vcf')
    set_attr('Id', get_attr('HrefVariants').split('/').last)
    return api.get_variant_metadata(get_attr('Id'), 'txt')
  end

end

end # module BaseSpace
end # module Bio

