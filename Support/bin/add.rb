require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"

unless ARGV.empty?
  STDOUT << Subversion.run("add", ARGV)
  TextMate.rescan_project
end
