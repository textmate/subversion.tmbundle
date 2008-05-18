require 'English'
require 'ostruct'
require 'pathname'
require 'optparse'

require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/shelltokenize"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/commit_transaction"

$options = OpenStruct.new(
  :output_format => :HTML,
  :dry_run => false
)

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options] [files]"
  opts.separator ""
  opts.separator "Specific options:"

  opts.on("--output=TYPE", [:HTML, :plaintext, :terminal], "Select format of output (HTML, plaintext, terminal).")   do |format|
    $options.output_format = format
  end

  opts.on_tail("--help", "Display help.") do
    puts opts
    exit
  end

  opts.on_tail("--dry-run", "Go through the motions, but don't actually commit anything.") do
    $options.dry_run = true
  end
end

opts.parse!
paths_to_commit = (ARGV.empty?) ? TextMate::selected_paths_array : ARGV
transaction = Subversion::CommitTransaction.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'], paths_to_commit)

if transaction.has_mods?
  case $options.output_format
  when :plaintext
    out = transaction.commit
    puts out unless out.nil?
  when :HTML
    out = transaction.commit(true)
    unless out.nil?
      revision_string = $& if out =~ /Committed revision \d*./

      TextMate::UI.simple_notification(
        :title => 'Commit Result',
        :summary => (revision_string || 'Error occurred'),
        :log => out
      )
    end
  end
else
  str = "No files modified; nothing to commit.\n" 
  transaction.paths.each do | path |
    str = " • " + path + "\n"
  end
  case $options.output_format
  when :plaintext
    puts str
  when :HTML
    TextMate::UI.simple_notification(:title => 'Commit Result', :summary => "No files modified; nothing to commit.", :log => str)
  end
end