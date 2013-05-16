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

class UndefinedParameterError < StandardError
    def initialize(value)
        super("The following parameter must be defined: #{value}")
    end
end

class UnknownParameterError < StandardError
    def initialize(value)
        super("#{value} is not regcognized as a parameter for this call")
    end
end

class IllegalParameterError < StandardError
    def initialize(value, legal)
        super("#{value} is not well-defined, legal options are #{legal}")
    end
end
    
class WrongFiletypeError < StandardError
    def initialize(filetype)
        super("This data request is not available for file #{filetype}")
    end
end
    
class NoResponseError < StandardError
    def initialize(value)
        super("No response was returned from the server for this request")
    end
end
    
class ModelNotInitializedError < StandardError
    def initialize(value)
        super("The request cannot be completed as model has not been initialized - #{value}")
    end
end

end # module BaseSpace
end # module Bio

