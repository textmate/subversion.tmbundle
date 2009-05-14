require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/event"

unless ARGV.empty?
  base = Pathname.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'])
  relative_args = ARGV.collect { |a| Pathname.new(a).relative_path_from(base) }
  Dir.chdir(base) do
    out = Subversion.run("add", relative_args)
    TextMate.event("info.scm.add.svn", "svn add", out)
  end
  TextMate.rescan_project
end
