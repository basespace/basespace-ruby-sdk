
require 'rubygems'
require 'rspec'

load 'lib/basespaceruby/basespaceerror.rb'

value = 'testvalue'
legal = 'legalcases'

describe BaseSpaceRuby::UndefinedParameterError do
    describe "initialization" do
        it "passing: #{value}" do
            BaseSpaceRuby::UndefinedParameterError.new(value).message.should match("The following parameter must be defined: #{value}")
        end
        it "raising exception" do
            expect { raise BaseSpaceRuby::UndefinedParameterError, value }.to raise_exception(BaseSpaceRuby::UndefinedParameterError)
        end
    end
end

describe BaseSpaceRuby::UnknownParameterError do
    describe "initialization" do
        it "passing: #{value}" do
            BaseSpaceRuby::UnknownParameterError.new(value).message.should match("#{value} is not regcognized as a parameter for this call")
        end
        it "raising exception" do
            expect { raise BaseSpaceRuby::UnknownParameterError, value }.to raise_exception(BaseSpaceRuby::UnknownParameterError)
        end
    end
end

describe BaseSpaceRuby::IllegalParameterError do
    describe "initialization" do
        it "passing: #{value}" do
            BaseSpaceRuby::IllegalParameterError.new(value, legal).message.should match("#{value} is not well-defined, legal options are #{legal}")
        end
        it "raising exception" do
            expect { raise BaseSpaceRuby::IllegalParameterError.new(value, legal) }.to raise_exception(BaseSpaceRuby::IllegalParameterError)
        end
    end
end

describe BaseSpaceRuby::WrongFiletypeError do
    describe "initialization" do
        it "passing: #{value}" do
            BaseSpaceRuby::WrongFiletypeError.new(value).message.should match("This data request is not available for file #{value}")
        end
        it "raising exception" do
            expect { raise BaseSpaceRuby::WrongFiletypeError, value }.to raise_exception(BaseSpaceRuby::WrongFiletypeError)
        end
    end
end

describe BaseSpaceRuby::NoResponseError do
    describe "initialization" do
        it "passing: #{value}" do
            BaseSpaceRuby::NoResponseError.new(value).message.should match("No response was returned from the server for this request")
        end
        it "raising exception" do
            expect { raise BaseSpaceRuby::NoResponseError, value }.to raise_exception(BaseSpaceRuby::NoResponseError)
        end
    end
end

describe BaseSpaceRuby::ModelNotInitializedError do
    describe "initialization" do
        it "passing: #{value}" do
            BaseSpaceRuby::ModelNotInitializedError.new(value).message.should match("The request cannot be completed as model has not been initialized - #{value}")
        end
        it "raising exception" do
            expect { raise BaseSpaceRuby::ModelNotInitializedError, value }.to raise_exception(BaseSpaceRuby::ModelNotInitializedError)
        end
    end
end

