require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'

TextMate::UI.alert(:critical, "An SVN Bundle error occurred", "tmsvn.rb received no arguments", "OK") if ARGV.empty?

script = ARGV.shift
out, err = TextMate::Process.run(ENV['TM_RUBY'], "#{File.dirname(__FILE__)}/#{script}.rb", ARGV)

STDOUT << out
TextMate::UI.alert(:critical, "An error occurred within the Subversion bundle", err, "OK") if $? != 0 and not err.empty?
exit $?.exitstatus