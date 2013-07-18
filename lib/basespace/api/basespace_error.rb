# Copyright 2012-2013 Joachim Baran
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

# Raised when a parameter in a call was not defined.
class UndefinedParameterError < StandardError
  # Create a new instance of the error.
  #
  # +parameter+:: Name of the parameter that is not defined.
  def initialize(parameter)
    super("The following parameter must be defined: #{parameter}")
  end
end

# Raised when a parameter was provided that is unknown to the implementation.
class UnknownParameterError < StandardError
  # Create a new instance of the error.
  #
  # +parameter+:: Name of the parameter that is not recognized.
  def initialize(parameter)
    super("#{parameter} is not regcognized as a parameter for this call")
  end
end

# Raised when a parameter was set to an invalid value.
class IllegalParameterError < StandardError
  # Create a new instance of the error.
  #
  # +value+:: Value that was passed and which is of an invalid value.
  # +legal+:: Listing of valid values.
  def initialize(value, legal)
    super("#{value} is not well-defined, legal options are #{legal}")
  end
end

# Raised when an unsupported or unsuitable file type is encountered.
class WrongFiletypeError < StandardError
  # Create a new instance of the error.
  #
  # +filetype+:: Filetype that was intended to be used.
  def initialize(filetype)
    super("This data request is not available for file #{filetype}")
  end
end

# Raised when no response has been received from the API server (in a certain amount of time).
class NoResponseError < StandardError
  # Create a new instance of the error.
  #
  # +value+:: Value that was provided with the request.
  def initialize(value)
    super("No response was returned from the server for this request - #{value}")
  end
end

# Raised when the model for holding data has not been initialized yet.
class ModelNotInitializedError < StandardError
  # Create a new instance of the error.
  #
  # +value+:: Value that was provided with the request.
  def initialize(value)
    super("The request cannot be completed as model has not been initialized - #{value}")
  end
end

end # module BaseSpace
end # module Bio

