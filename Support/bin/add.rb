require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/event"

unless ARGV.empty?
  out = Subversion.run("add", ARGV)
  TextMate.event("info.scm.add.svn", "svn add", out)
  TextMate.rescan_project
end
