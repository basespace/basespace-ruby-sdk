# Copyright 2012-2013 Joachim Baran, Toshiaki Katayama
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

require 'rubygems'
require 'rspec'

require 'basespace'

value = 'testvalue'
legal = 'legalcases'

describe Bio::BaseSpace::UndefinedParameterError do
    describe "initialization" do
        it "passing: #{value}" do
            Bio::BaseSpace::UndefinedParameterError.new(value).message.should match("The following parameter must be defined: #{value}")
        end
        it "raising exception" do
            expect { raise Bio::BaseSpace::UndefinedParameterError, value }.to raise_exception(Bio::BaseSpace::UndefinedParameterError)
        end
    end
end

describe Bio::BaseSpace::UnknownParameterError do
    describe "initialization" do
        it "passing: #{value}" do
            Bio::BaseSpace::UnknownParameterError.new(value).message.should match("#{value} is not regcognized as a parameter for this call")
        end
        it "raising exception" do
            expect { raise Bio::BaseSpace::UnknownParameterError, value }.to raise_exception(Bio::BaseSpace::UnknownParameterError)
        end
    end
end

describe Bio::BaseSpace::IllegalParameterError do
    describe "initialization" do
        it "passing: #{value}" do
            Bio::BaseSpace::IllegalParameterError.new(value, legal).message.should match("#{value} is not well-defined, legal options are #{legal}")
        end
        it "raising exception" do
            expect { raise Bio::BaseSpace::IllegalParameterError.new(value, legal) }.to raise_exception(Bio::BaseSpace::IllegalParameterError)
        end
    end
end

describe Bio::BaseSpace::WrongFiletypeError do
    describe "initialization" do
        it "passing: #{value}" do
            Bio::BaseSpace::WrongFiletypeError.new(value).message.should match("This data request is not available for file #{value}")
        end
        it "raising exception" do
            expect { raise Bio::BaseSpace::WrongFiletypeError, value }.to raise_exception(Bio::BaseSpace::WrongFiletypeError)
        end
    end
end

describe Bio::BaseSpace::NoResponseError do
    describe "initialization" do
        it "passing: #{value}" do
            Bio::BaseSpace::NoResponseError.new(value).message.should match("No response was returned from the server for this request")
        end
        it "raising exception" do
            expect { raise Bio::BaseSpace::NoResponseError, value }.to raise_exception(Bio::BaseSpace::NoResponseError)
        end
    end
end

describe Bio::BaseSpace::ModelNotInitializedError do
    describe "initialization" do
        it "passing: #{value}" do
            Bio::BaseSpace::ModelNotInitializedError.new(value).message.should match("The request cannot be completed as model has not been initialized - #{value}")
        end
        it "raising exception" do
            expect { raise Bio::BaseSpace::ModelNotInitializedError, value }.to raise_exception(Bio::BaseSpace::ModelNotInitializedError)
        end
    end
end

