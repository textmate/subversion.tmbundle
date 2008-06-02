#!/usr/bin/env ruby

require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'

TextMate::UI.alert(:critical, "An SVN Bundle error occurred", "tmsvn.rb received no arguments", "OK") if ARGV.empty?

ENV['TM_SVN'] ||= 'svn'
ENV['TM_RUBY'] ||= 'ruby'

TextMate.require_cmd(ENV['TM_SVN'], "If you have installed svn, then you need to either <a href=\"help:anchor='search_path'%20bookID='TextMate%20Help'\">update your <tt>PATH</tt></a> or set the <tt>TM_SVN</tt> shell variable (e.g. in Preferences / Advanced)")

script = ARGV.shift
out, err = TextMate::Process.run(ENV['TM_RUBY'], "#{File.dirname(__FILE__)}/#{script}.rb", ARGV)

STDOUT << out
TextMate::UI.alert(:critical, "An error occurred within the Subversion bundle", err, "OK") if $? != 0 and not err.empty?
exit $?.exitstatus