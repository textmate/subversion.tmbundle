require 'optparse'
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/notify"

path_base = nil

optparser = OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename(__FILE__)} [options] [files]"
  optparser.separator ""
  optparser.separator "Specific options:"

  optparser.on("--base=PATH", "If present, paths will be displayed to the user relative to this") do |base|
    path_base = base
  end
end

files = ARGV

unless files.empty?
  path_base = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || nil if path_base.nil?
  title = "Are you sure you want to revert the following " + ((files.length > 1) ? "#{files.length} files" : "file") + '?'
  display_files = nil
  if path_base.nil?
    display_files = files
  else
    path_base += "/" unless path_base =~ /\/$/
    path_base_escaped = Regexp.escape(path_base)
    display_files = files.map{ |f| f.sub(/^#{path_base_escaped}/, '') }
  end

  file_list = display_files.map{|f| "• #{f}"}.join("\n")
  if TextMate::UI.request_confirmation(:title => title, :button1 => "Revert", :prompt => file_list)
    Subversion.run("revert", files)
    TextMate.notify("SVN Revert", "svn revert", file_list)
    TextMate.rescan_project
  end
end