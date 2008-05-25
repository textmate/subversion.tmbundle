require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV['TM_SUPPORT_PATH'] + '/lib/progress'

dir = File.dirname(__FILE__)
require dir + '/status_listing'
require dir + '/commit_result'
require dir + '/log'

module Subversion
  class << self

    def svn
      ENV['TM_SVN'] || 'svn'
    end

    def run(*cmd, &error_handler)
      out, err = TextMate::Process.run(svn, cmd, :buffer => false)

      if $? != 0
        if error_handler.nil?
          TextMate::UI.alert(:critical, "The 'svn' command produced an error", err, "OK")
          exit 1
        else
          error_handler.call(err)
        end
      else
        return out
      end
    end

    def status(*dirs) 
      StatusListing.new(Subversion.run("status", "--xml", *dirs))
    end

    def commit(*args)
      CommitResult.new(Subversion.run("commit", *args))
    end
    
    def log(quiet, file)
      log_getter = Proc.new { Log.new(Subversion.run("log", "--xml", file)) }
      if quiet
        log_getter.call
      else
        TextMate::call_with_progress(:title => "svn log", :message => "Reading log of #{File.basename(file)}", &log_getter)
      end
    end
    
  end
end