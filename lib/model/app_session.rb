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

# AppLaunch contains the data returned 
class AppSession
  attr_reader :swagger_types
  attr_accessor :id, :href, :type, :user_created_by, :date_created, :status, :status_summary, :application, :references

  def initialize
    @swagger_types = {
      :id               => 'str',
      :href             => 'str',
      :type             => 'str',
      :user_created_by  => 'User',
      :date_created     => 'datetime',
      :status           => 'str',
      :status_summary   => 'str',
      :application      => 'Application',
      :references       => 'list<AppSessionLaunchObject>'
    }

    # [TODO] UserUserCreatedBy (typo of UserCreatedBy?)
    @user_created_by    = nil #  The user that triggered your application
    @id                 = nil
    @status             = nil
    @status_summary     = nil
    @href               = nil #  The URI of BaseSpace
    @date_created       = nil #  The datetime the user acted in BaseSpace
    @references         = nil
  end

  def to_s
    return "App session by #{@user_created_by} - Id: #{@id} - status: #{@status}"
  end

  def to_str
    self.to_s
  end

  def serialize_references(api)
    ref = []
    @references.each do |r|
      res = r.serialize_object(api)  # AppSessionLaunchObject
      ref << res
    end
    @references = ref
    return self
  end
    
  def can_work_on
    return ['running'].include?(@status.downcase)
  end
    
  # Sets the status of the AppSession (note: once set to 'completed' or 'aborted' no more work can be done to the instance)
  # 
  # :param api: An instance of BaseSpaceAPI
  # :param Status: The status value, must be completed, aborted, working, or suspended
  # :param Summary: The status summary
  def set_status(api, status, summary)
    if @status.downcase == 'complete' or @status.downcase == 'aborted'
      raise "The status of AppSession = #{self.to_s} is #{@status}, no further status changes are allowed."
    end

    # To prevent the AppResult object from being in an inconsistent state
    # and having two identical objects floating around, we update the current object
    # and discard the returned object
    new_session      = api.set_app_session_state(@id, @status, @summary)
    @status          = new_session.status
    @status_summary  = new_session.status_summary
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
