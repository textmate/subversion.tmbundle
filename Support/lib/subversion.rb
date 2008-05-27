require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV['TM_SUPPORT_PATH'] + '/lib/progress'

dir = File.dirname(__FILE__)
require dir + '/model/status_listing'
require dir + '/model/commit_result'
require dir + '/model/log'
require dir + '/model/update_result'

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
      XmlStatusParser.new(Subversion.run("status", "--xml", *dirs)).status
    end

    def commit(*args)
      CommitResult.new(Subversion.run("commit", *args))
    end
    
    def log(file, options = {:quiet => false, :verbose => false})
      log_getter = Proc.new { Subversion::XmlLogParser.new(Subversion.run("log", "--xml", (options[:verbose]) ? '--verbose' : nil, file)).log }
      if options[:quiet]
        log_getter.call
      else
        TextMate::call_with_progress(:title => "svn log", :message => "Reading log of #{File.basename(file)}", &log_getter)
      end
    end
    
    def update(base, files, options = {:quiet => false})
      result = nil
      updater = Proc.new do
        Dir.chdir(base) do
          update_text = Subversion.run("update", *files)
          result = Subversion::UpdateResult::PlainTextParser.new(base, update_text).update_result
        end
      end        
      if options[:quiet]
        updater.call
      else
        TextMate::call_with_progress(
          :title => "svn update", 
          :message => "Updating #{File.basename(base)}#{" (selection)" unless files.empty?}", 
          &updater
        )
      end
    end
  end
end