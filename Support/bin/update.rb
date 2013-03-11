require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/event"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/view/update_result_html"

base = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.pwd
ARGV.delete_if { |f| f == base }

result = Subversion.update(base, ARGV)
if result.updates?
  if result.changes?
    view = Subversion::UpdateResult::HTMLView.new(result)
    view.render
    TextMate.exit_show_html
  else
    TextMate.event("info.scm.update.nochanges.svn", "Updated to r#{result.revision}", "No files changed.")
  end
else
  msg = (ARGV.empty?) ? "You are up to date." : "The selected files are up to date."
  TextMate.event("info.scm.update.noupdates.svn", "Already at r#{result.revision}", msg)
end