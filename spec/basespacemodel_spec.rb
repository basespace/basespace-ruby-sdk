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

require 'rubygems'
require 'rspec'

require 'bio-basespace-sdk'

attributes = { "Id" => "X10231", "Source" => "Test", "SpeciesName" => "Homo sapiens" }

describe Bio::BaseSpace::Model do
    describe "initialization" do
        it "empty model" do
            expect(Bio::BaseSpace::Model.new).to be_an_instance_of(Bio::BaseSpace::Model)
        end
        
        it "test attributes are nil; tested attributes: #{attributes.keys.join(', ')}" do
            attributes.keys.each { |attribute|
              expect(Bio::BaseSpace::Model.new.get_attr(attribute)).to be_nil
            }
        end
    end

    describe "attribute manipulation" do
        it "getter/setter: consistency" do
            model = Bio::BaseSpace::Model.new
            attributes.keys.each { |attribute|
              expect(model.get_attr(attribute)).to be_nil
              model.set_attr(attribute, attributes[attribute])
              expect(model.get_attr(attribute)).to be(attributes[attribute])
            }
        end

        it "getter/setter: overwrite attribute value" do
            model = Bio::BaseSpace::Model.new
            attributes.keys.each { |attribute|
              model.set_attr(attribute, attributes[attribute])
              expect(model.get_attr(attribute)).to be(attributes[attribute])
              new_value = "#{attributes[attribute]}-modified"
              model.set_attr(attribute, new_value)
              expect(model.get_attr(attribute)).to_not be(attributes[attribute])
              expect(model.get_attr(attribute)).to be(new_value)
            }
        end
    end    
end

