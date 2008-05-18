require ENV['TM_BUNDLE_SUPPORT'] + "/lib/subversion"
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + "/lib/ui"
require ENV['TM_SUPPORT_PATH'] + "/lib/progress"
require 'shellwords'

module Subversion

  class CommitTransaction

    attr_accessor :base
    attr_accessor :paths
    attr_accessor :status
    attr_accessor :diff
    attr_accessor :commit_window
    attr_accessor :status_helper

  private
    def matches_to_paths(matches)
      paths = matches.collect {|m| Pathname.new(m[2]).realpath.to_s }
      paths.collect { |path| path.sub(/^#{Regexp.escape(@base)}\//, '') }
    end

    def matches_to_status(matches)
      # collect the status, and replace prefix spaces with underscores so command-line argument passing works later
      matches.collect {|m| m[0]}.map {|m| m.rstrip.gsub(/\s/, '_')}
    end

  public
    def initialize(base, paths)
      @base = base
      Dir.chdir(@base)
      @paths = paths
      @status = Subversion.status(*@paths)
      @diff = ENV['TM_SVN_DIFF_CMD'] || 'diff'
      @commit_window = ENV['CommitWindow'] || ENV['TM_SUPPORT_PATH'] + '/bin/CommitWindow.app/Contents/MacOS/CommitWindow'
      @status_helper = ENV['TM_BUNDLE_SUPPORT'] + "/commit_status_helper.rb"
    end

    def has_mods?
      not @status.empty?
    end

    def commit(show_progress = false)
      commit_paths_array = matches_to_paths(@status)
      commit_status = matches_to_status(@status).join(":")

      commit_path_text = commit_paths_array.collect{|path| path.quote_filename_for_shell }.join(" ")
      
      commit_args = Shellwords.shellwords(
        %x{"#{@commit_window}" 2>/dev/console --diff-cmd "#{Subversion.svn},diff,--diff-cmd,#{@diff}" \
          --status #{commit_status} \
          --action-cmd "!:Remove,#{Subversion.svn},rm" \
          --action-cmd "?:Add,#{Subversion.svn},add" \
          --action-cmd "A:Mark Executable,#{@status_helper},propset,svn:executable,true" \
          --action-cmd "A,M,D,C:Revert,#{@status_helper},revert" \
          --action-cmd "C:Resolved,#{@status_helper},resolved" \
          #{commit_path_text} \
        }
      )


      if ($CHILD_STATUS != 0)
        nil # User cancelled
      else
        out = ""
        commit = proc { out = Subversion.commit("--force-log", *commit_args) }
        if show_progress
          TextMate.call_with_progress(:title => 'Subversion Commit', :message => 'Transmitting file data', &commit)
        else
          commit.call
        end
        out
      end
    end

  end
end