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

module Bio
module BaseSpace

class ResponseStatus
  attr_reader :swagger_types
  attr_accessor :message, :errors, :error_code, :stack_trace

  def initialize
    @swagger_types = {
      :message      => 'str',
      :errors       => 'list<Str>',
      :error_code   => 'str',
      :stack_trace  => 'str'
    }

    @message        = nil # str
    @errors         = nil # list<Str>
    @error_code     = nil # str
    @stack_trace    = nil # str
  end
end

end # module BaseSpace
end # module Bio

