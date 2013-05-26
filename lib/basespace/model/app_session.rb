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

require 'basespace/model'

module Bio
module BaseSpace

# AppLaunch contains the data returned 
class AppSession < Model
  def initialize
    @swagger_types = {
      'Id'             => 'str',
      'Href'           => 'str',
      'Type'           => 'str',
      'UserCreatedBy'  => 'User',
      'DateCreated'    => 'datetime',
      'Status'         => 'str',
      'StatusSummary'  => 'str',
      'Application'    => 'Application',
      'References'     => 'list<AppSessionLaunchObject>',
    }
    @attributes = {
      'Id'             => nil,
      'Href'           => nil, # The URI of BaseSpace
      'Type'           => nil,
      # [TODO] UserUserCreatedBy in Python code would be typo of UserCreatedBy (bug in Python SDK)
      'UserCreatedBy'  => nil, # The user that triggered your application
      'DateCreated'    => nil, # The datetime the user acted in BaseSpace
      'Status'         => nil,
      'StatusSummary'  => nil,
      'Application'    => nil,
      'References'     => nil,
    }
  end

  def to_s
    return "App session by #{get_attr('UserCreatedBy')} - Id: #{get_attr('Id')} - status: #{get_attr('Status')}"
  end

  def serialize_references(api)
    ref = []
    # [TODO] should this attribute initialized with []?
    get_attr('References').each do |r|
      res = r.serialize_object(api)  # AppSessionLaunchObject
      ref << res
    end
    set_attr('References', ref)
    return self
  end
    
  def can_work_on
    return ['running'].include?(get_attr('Status').downcase)
  end
    
  # Sets the status of the AppSession (note: once set to 'completed' or 'aborted' no more work can be done to the instance)
  # 
  # :param api: An instance of BaseSpaceAPI
  # :param Status: The status value, must be completed, aborted, working, or suspended
  # :param Summary: The status summary
  def set_status(api, status, summary)
    current_status = get_attr('Status')
    if current_status.downcase == 'complete' or current_status.downcase == 'aborted'
      raise "The status of AppSession = #{self.to_s} is #{current_status}, no further status changes are allowed."
    end

    # To prevent the AppResult object from being in an inconsistent state
    # and having two identical objects floating around, we update the current object
    # and discard the returned object
    new_session = api.set_app_session_state(get_attr('Id'), status, summary)
    set_attr('Status', new_session.status)
    set_attr('StatusSummary', new_session.status_summary)
    return self
  end
 
end
 
end # module BaseSpace
end # module Bio

# deprecated
#    def getLaunchType(self):
#        '''
#        Returns a list [<launch type name>, list of objects] where <launch type name> is one of Projects, Samples, Analyses 
#        '''
#        try: 
#            self.Projects
#            return ['Projects', self.Projects]
#        except: e=1
#        try: 
#            self.Samples
#            return ['Samples', self.Samples]
#        except: e=1
#        try: 
#            self.Analyses
#            return ['Analyses', self.Analyses]
#        except: e=1
