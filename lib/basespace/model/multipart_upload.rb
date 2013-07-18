# Copyright 2013 Toshiaki Katayama, Joachim Baran
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

require 'digest/md5'
require 'base64'

module Bio
module BaseSpace

# Multipart file upload helper class.
#
# TODO This file is not yet ported as the multipartFileUpload class is
# just mentioned in the comment section of the BaseSpaceAPI file.
class UploadTask

  # Create a new upload task object.
  #
  # +api+:: BaseSpaceAPI instance.
  # +bs_file_id+:: BaseSpace file ID.
  # +part+:: Part number of the multi-part upload.
  # +total+:: Total number of parts in the multi-part upload.
  # +myfile+:: Local file to be uploaded.
  # +attempt+:: Number of attempts that the file was previously uploaded (upload tries).
  def initialize(self, api, bs_file_id, part, total, myfile, attempt)
    @api         = api
    @part        = part       # part number
    @total       = total       # out of total part count
    @file        = myfile      # the local file to be uploaded
    @bs_file_id  = bs_file_id  # the baseSpace fileId
    @attempt     = attempt     # the # of attempts we've made to upload this guy
    @state       = 0           # 0=pending, 1=ran, 2=error
  end
    
  # Returns the filename (without path) if the file to be uploaded.
  def upload_file_name
    return @file.split('/').last + '_' + @part.to_s
  end
  
  # Upload a part of the file.
  def call
    # read the byte string in
    @attempt += 1
    trans_file = @file + @part.to_s
    cmd = "split -d -n #{@part}/#{@total} #{@file}"
    out = `#{cmd}`
    File.open(trans_file, "w") do |f|
      f.write(out)
    end
    # [TODO] confirm whether md5(out).digest is equivalent to MD5.digest (or MD5.hexdigest?)
    @md5 = Base64.encode64(Digest::MD5.digest(out))
    res = self.api.upload_multipart_unit(@bs_file_id, @part, @md5, trans_file)
    # puts "my result #{res}"
    File.delete(trans_file)
    if res['Response'].has_key?('ETag')
      @state = 1          # case things went well
    else
      @state = 2
    end
    return self
  end
   
  # Returns information about which part of which file is uploaded, including the total number of parts.
  def to_s
    return "#{@part} / #{@total} - #{@file}"
  end

end # class UploadTask
    
class Consumer  # [TODO] inherit multiprocessing.Process
  def initialize(task_queue, result_queue, pause_event, halt_event)
    # [TODO] http://stackoverflow.com/questions/710785/working-with-multiple-processes-in-ruby
    #        http://stackoverflow.com/questions/855805/please-introduce-a-multi-processing-library-in-perl-or-ruby
    #        http://docs.python.jp/2.6/library/multiprocessing.html
    #multiprocessing.Process.__init__(self)
    @task_queue    = task_queue
    @result_queue  = result_queue
    @pause         = pauseEvent
    @halt          = haltEvent
  end
  
  # [TODO]
  def run
    proc_name = self.name
    while True:
      unless self.pause.is_set()
        next_task = self.task_queue.get()
      end
            
      if next_task is None or self.halt.is_set(): # check if we are out of jobs or have been halted
        # Poison pill means shutdown
        print '%s: Exiting' % proc_name
        self.task_queue.task_done()
        break
      elsif self.pause.is_set():                   # if we have been paused, sleep for a bit then check back
        print '%s: Paused' % proc_name 
        time.sleep(3)                                       
      else:                                       # do some work
        print '%s: %s' % (proc_name, next_task)
        answer = next_task()
        self.task_queue.task_done()
        if answer.state == 1:                   # case everything went well
          self.result_queue.put(answer)
        else:                                   # case something sent wrong
          if next_task.attempt < 3:
            self.task_queue.put(next_task)  # queue the guy for a retry
          else:                               # problems, shutting down this party
            self.halt.set()                 # halt all other process
          end
        end
      end
    end
    return
  end
end # class Consumer


class MultipartUpload:
  def initialize(api, a_id, local_file, file_object, cpu_count, part_size, temp_dir, verbose)
    @api            = api
    @analysis_id    = a_id
    @local_file     = local_file
    @remote_file    = file_object
    @part_size      = part_size
    @cpu_count      = cpu_count
    @verbose        = verbose
    @temp_dir       = temp_dir
    @status         = 'Initialized'
    @start_time     = -1
    #@repeat_count  = 0             # number of chunks we uploaded multiple times
    setup
  end

  def to_s
    # [TODO] fix this.
    return "MPU -  Stat: " + @status +  ", LiveThread: " + str(self.getRunningThreadCount()) + \
                ", RunTime: " + str(self.getRunningTime())[:5] + 's' + \
                ", Q-size " + str(self.tasks.qsize()) + \
                ", Completed " + str(self.getProgressRatio()) + \
                ", AVG TransferRate " + self.getTransRate() + \
                ", Data transfered " + str(self.getTotalTransfered())[:5] + 'Gb'
  end
    
  def to_str
    return self.inspect
  end
    
  def run
    while @status == 'Paused' or __check_queue__
      time.sleep(self.wait)
    end
  end

  def setup
    # determine the 
    totalSize = os.path.getsize(self.localFile)
    fileCount = int(math.ceil(totalSize/(self.partSize*1024.0*1000)))
    
    if self.verbose: 
      print "TotalSize " + str(totalSize)
      print "Using split size " + str(self.partSize) +"Mb"
      print "Filecount " + str(fileCount)
      print "CPUs " + str(self.cpuCount)
    end
    
    # Establish communication queues
    self.tasks = multiprocessing.JoinableQueue()
    self.completedPool = multiprocessing.Queue()
    for i in xrange(1,fileCount+1):         # set up the task queue
      t = uploadTask(self.api,self.remoteFile.Id,i, fileCount, self.localFile, 0)
      self.tasks.put(t)
    end
    self.totalTask  = self.tasks.qsize()
    
    # create consumers
    self.pauseEvent = multiprocessing.Event()
    self.haltEvent = multiprocessing.Event()
    if self.verbose:
      print 'Creating %d consumers' % self.cpuCount
      print "queue size " + str(self.tasks.qsize())
    end
    self.consumers = [ Consumer(self.tasks, self.completedPool,self.pauseEvent,self.haltEvent) for i in xrange(self.cpuCount) ]
      for c in self.consumers: self.tasks.put(None)   # add poisson pill
    end
  end
        
  def __cleanUp__(self):
    self.stats[0] += 1
  end
    
  def startUpload(self,returnOnFinish=0,testInterval=5):
    if self.Status=='Terminated' or self.Status=='Completed':
      raise Exception('Cannot resume a ' + self.Status + ' multi-part upload session.')
        
    if self.Status == 'Initialized':
      self.StartTime = time.time()
      for w in self.consumers:
        w.start()
    if self.Status == 'Paused':
      self.pauseEvent.clear()
    self.Status = 'Running'
        
    # If returnOnFinish is set 
    if returnOnFinish:
      i=0
      while not self.hasFinished():
        if self.verbose and i: print str(i) + ': ' + str(self)
        time.sleep(testInterval)
        i+=1
      self.finalize()
      return 1
    else:
      return 1
    end
  end
    
  def finalize(self):
    if self.getRunningThreadCount():
      raise Exception('Cannot finalize a transfer with running threads.')
    if self.Status=='Running':
      # code here for 
      self.Status=='Completed'
    else:
      raise Exception('To finalize the status of the transfer must be "Running."')
    end
  end
    
  def hasFinished(self):
    if self.Status == 'Initialized': return 0
    return not self.getRunningThreadCount()>0
  end
    
  def pauseUpload(self):
    self.pauseEvent.set()
    self.Status = 'Paused'
  end
    
  def haltUpload(self):
    for c in self.consumers: c.terminate()
    self.Status = 'Terminated'
  end
    
  def getStatus(self):
    return self.Status
  end
    
  def getFileResponse(self):
    return self.remoteFile
  end
    
  def getRunningThreadCount(self):
    return sum([c.is_alive() for c in self.consumers])
  end

  def getTransRate(self):
    # tasks completed                        size of file-parts 
    return str((self.totalTask - self.tasks.qsize())*self.partSize/self.getRunningTime())[:6] + ' mb/s'
  end
    
  def getRunningTime(self):
    if self.StartTime==-1: return 0
    else: return time.time() - self.StartTime
  end
  
  # Returns the total data amoun transfered in Gb
  def getTotalTransfered(self):
    return float((self.totalTask - self.tasks.qsize())*self.partSize)/1000.0
  end
    
  def getProgressRatio(self):
    currentQ = float(self.tasks.qsize() - len(self.consumers))
    return str(float(self.totalTask - currentQ)/self.totalTask)[:6]
  end

end # class MultipartUpload

end # module BaseSpace
end # module Bio

