require ENV['TM_SUPPORT_PATH'] + '/lib/tm_process'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'

module Subversion
  class << self

    def svn
      ENV['TM_SVN']
    end

    def run(*cmd, &error_handler)
      out, err = TextMate::Process.run([svn, cmd].flatten, :sync => true)

      if $? != 0
        if error_handler.nil?
          TextMate.exit_show_tool_tip err
        else
          error_handler.call(err)
        end
      else
        return out
      end
    end

    def status(*dirs)
      Subversion.run("status", *dirs).scan(/^(.....)(\s+)(.*)\n/)
    end

    def commit(*args)
      Subversion.run("commit", *args)
    end

  end
end