require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/event"

unless ARGV.empty?
  TextMate.event("info.scm.resolved.svn", "svn resolved", Subversion.run("resolved", ARGV))
  TextMate.rescan_project
end
