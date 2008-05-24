require 'ostruct'
require 'pathname'
require 'optparse'

require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/shelltokenize"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/commit_transaction"

options = OpenStruct.new(
  :output_format => :TM,
  :dry_run => false
)

optparser = OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename(__FILE__)} [options] [files]"
  optparser.separator ""
  optparser.separator "Specific options:"

  output_formats = [:TM, :plaintext]
  optparser.on("--output=TYPE", output_formats, "Select format of output #{output_formats.inspect}.")   do |format|
    options.output_format = format
  end

  optparser.on_tail("--help", "Display help.") do
    puts optparser
    exit
  end

  optparser.on_tail("--dry-run", "Go through the motions, but don't actually commit anything.") do
    options.dry_run = true
  end
end

optparser.parse!

paths_to_commit = (ARGV.empty?) ? TextMate::selected_paths_array : ARGV
transaction = Subversion::CommitTransaction.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'], paths_to_commit)

if transaction.has_mods?
  transaction.show_progress = (options.output_format == :TM)
  result = transaction.commit
  unless result.nil?
    if result.commits?
      case options.output_format
      when :plaintext
        puts result.out
      when :TM
        TextMate::UI.alert(:informational, result.to_s, result.files.map{ |file| "• #{file}" }.join("\n"), "OK")
      end
    end
  end
else
  header = "No files modified; nothing to commit"
  body = transaction.paths.map{ |path| "• #{path}" }.join("\n")
  case options.output_format
  when :plaintext
    puts "#{header}\n\n#{body}"
  when :TM
    TextMate::UI.alert(:informational, header, body, "OK")
  end
end