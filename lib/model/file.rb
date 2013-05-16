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

require 'api/basespace_error'

module Bio
module BaseSpace

# Represents a BaseSpace file object.
class File
  attr_reader :swagger_types
  attr_accessor :name, :href_coverage, :href_parts, :date_created, :upload_status, :id, :href, :href_content, :href_variants, :content_type, :path, :size

  def initialize
    @swagger_types = {
      :name           => 'str',
      :href_coverage  => 'str',
      :href_parts     => 'str',
      :date_created   => 'str',
      :upload_status  => 'str',
      :id             => 'str',
      :href           => 'str',
      :href_content   => 'str',
      :href_variants  => 'str',
      :content_type   => 'str',
      :path           => 'str',
      :size           => 'int'
    }

    @name             = nil # str
    # If set, provides the relative Uri to fetch the mean coverage statistics for data stored in the file
    @href_coverage    = nil # str
    # If set, provides the relative Uri to fetch a list of completed file parts for multi-part file uploads in progress
    @href_parts       = nil # str
    @date_created     = nil # str
    @upload_status    = nil # str
    @id               = nil # str
    @href             = nil # str
    @href_content     = nil # str
    # If set, provides the relative Uri to fetch the variants stored in the file
    @href_variants    = nil # str
    @content_type     = nil # str
    @path             = nil # str
    @size             = nil # int
  end

  def to_s
    s = @name
    begin
      s += "- status: #{@upload_status}"
    rescue
      # [TODO] What to do with this?
      e = 1
    end
    return s 
  end

  def to_str
    return self.to_s
  end
    
  # Is called to test if the File instance has been initialized.
  # 
  # Throws:
  #     ModelNotInitializedError if the instance has not been populated yet.
  def is_init
    raise ModelNotInitializedError.new('The File model has not been initialized yet') unless @id
  end
        
  # Is called to test if the File instance is matches the filtype parameter 
  #       
  # :param filetype: The filetype for coverage or variant requests
  def is_valid_file_option(filetype)
    if filetype == 'bam'
      raise WrongFiletypeError.new(@name) unless @href_coverage
    end
    if filetype == 'vcf'
      raise WrongFiletypeError.new(@name) unless @href_variants
    end
  end                

  # Download the file object to the specified localDir or a byte range of the file, by specifying the 
  # start and stop byte in the range.
  # 
  # :param api: A BaseSpaceAPI with read access on the scope including the file object.
  # :param loadlDir: The local directory to place the file in.
  # :param range: Specify the start and stop byte of the file chunk that needs retrieved.
  def download_file(api, local_dir, range = [])
    unless range.empty?
      return api.file_download(@id,local_dir, @name, range)
    else
      return api.file_download(@id,local_dir, @name)
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
    @id = @href_coverage.split('/').last
    return api.get_interval_coverage(@id, chrom, start_pos, end_pos)
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
    @id = @href_variants.split('/').last
    return api.filter_variant_set(@id, chrom, start_pos, end_pos, 'txt')
  end

  # Return an object of CoverageMetadata for the selected region
  # 
  # :param api: An instance of BaseSpaceAPI.
  # :param Chrom: The chromosome of interest.
  def get_coverage_meta(api, chrom)
    is_init
    is_valid_file_option('bam')
    @id = @href_coverage.split('/').last
    return api.get_coverage_meta_info(@id, chrom)
  end

  # Return the the meta info for a VCF file as a VariantInfo object
  # 
  # :param api: An instance of BaseSpaceAPI
  def get_variant_meta(api)
    is_init
    is_valid_file_option('vcf')
    @id = @href_variants.split('/').last
    return api.get_variant_metadata(@id, 'txt')
  end

end

end # module BaseSpace
end # module Bio

