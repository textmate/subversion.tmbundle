#!/usr/bin/env ruby -w

require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/progress"
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "#{ENV['TM_SUPPORT_PATH']}/lib/shelltokenize" # for TextMate::selected_paths_array
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm_process"
require "#{ENV['TM_BUNDLE_SUPPORT']}/svn_revision_chooser"

module Subversion

	# Writes diff text to stdout for compatibility.
  def Subversion.diff_active_file( revision, command_description )
	
		error_handler = Proc.new do |error|
			TextMate::exit_show_tool_tip(error)
		end
	
		puts diff_working_copy_with_revision(:paths => TextMate::selected_paths_array,
																					:revision => revision,
																					:command_name => command_description,
																					:on_error => error_handler)  
  end

	# returns diff text
  def Subversion.diff_working_copy_with_revision( args )

		filepaths				= args[:paths]
		revision				= args[:revision]
		command					= args[:command_name]
		error_handler		=	args[:on_error]			|| lambda {|error| TextMate::UI.alert(:warning, "Could not complete diff operation", error)}
	
    if revision.nil? or revision.empty? or revision == "?"
	    revision = choose_revision(filepaths, "Diff two revs of #{File.basename(filepaths)}", 1)
	  elsif revision == ":"
	    revisions = choose_revision(filepaths, "Diff two revs of #{File.basename(filepaths)}", 2)
	    revision = revisions.join(':')
	  end

    svn         = ENV['TM_SVN'] || 'svn'
    diff_cmd    = ENV['TM_SVN_DIFF_CMD']
    diff_arg    = diff_cmd ? "--diff-cmd #{diff_cmd}" : ''

    error       = ''
    result      = ''

    TextMate::call_with_progress(:title => command, :message => "Accessing Subversion Repository…") do
      filepaths.each do |target_path|
        svn_header  = /\AIndex: #{Regexp.escape(target_path)}\n=+\n\z/
        out, err = TextMate::Process.run("#{e_sh svn} diff '-r#{revision}' #{diff_arg} #{e_sh target_path}")

        if $? != 0
          error << err
        elsif (custom_diff? or diff_cmd) and res =~ svn_header
          # Suppress output, as we only got a svn header (so likely diff-cmd opened its own window)
        else
          result << out
        end
      end

      error_handler.call(error)                     unless error.empty?
      error_handler.call("No differences found.")   if result.empty?
      result
    end
		result # should be redundant
  end

  # Returns true if ~/.subversion/config contains an uncommented entry for diff-cmd
  def Subversion.custom_diff?
    config_file = ENV['HOME'] + "/.subversion/config"
      
    if File.exists?(config_file)
      IO.foreach(config_file) do |line|
        return true if line =~ /^\s?diff-cmd\s?=\s?(.*)/
      end
    end
    
    return false
  end  
end


if __FILE__ == $0
  raise "Usage: #{File.basename(__FILE__)} revision heading [file]" if ARGV.size < 2 or ARGV.size > 3
  
  rev = ARGV[0]
  heading = ARGV[1]
  file = ARGV[2]
  
  if (file)
    Subversion.diff_working_copy_with_revision(:paths => file, :revision => rev, :command_name => heading)
  else  
    Subversion.diff_active_file(rev, heading)
  end
end
