require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

require File.dirname(__FILE__) + '/status_listing'
require File.dirname(__FILE__) + '/commit_result'

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

  end
end