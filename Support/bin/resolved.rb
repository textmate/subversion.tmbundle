require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"

unless ARGV.empty?
  $stdout << Subversion.run("resolved", ARGV)
  TextMate.rescan_project
end
