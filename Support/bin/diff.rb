#!/usr/bin/env ruby

require 'optparse'
require 'tempfile'
require 'pathname'

require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/process"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/operation_helper/revision_chooser"

base = nil
revision = 'BASE'
send_to_mate = false

optparser = OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename(__FILE__)} [options] [files]"
  optparser.separator ""
  optparser.separator "Specific options:"

  optparser.on("--base=PATH", "If present, paths will be displayed to the user relative to this") do |b|
    base = b
  end
  
  optparser.on("--send-to-mate", "If present, the diff will be sent to `mate` instead of STDOUT") do |s|
    send_to_mate = s
  end

  optparser.on("--revision=REVISION", "") do |r|
    revision = r
  end

end

optparser.parse!

files = ARGV

unless files.empty?
  base = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || nil if base.nil?
    
  if ["?", ":"].member? revision 
    abort "only one file argument allowed with --revision=#{revision}" if files.length > 1
    chooser = Subversion::RevisionChooser.new(files.first)
    revision = (revision == '?') ? chooser.revision : chooser.range
    exit 0 if revision.nil?
  end
    
  diff = Subversion.diff_files(base,revision,files)
  if diff.empty?
    TextMate::UI.alert(:warning, "No differences to show", "The selected files/revisions are identical.", "OK")
    TextMate.exit_discard
  else
    if send_to_mate
      tmp = Tempfile.new(files.map{ |f| File.basename(f) }.join('-'), ENV['TMPDIR'] || '/tmp')
      tmp.write diff
      tmp.flush
      out, err = TextMate::Process.run("mate", "-w", tmp.path)
      abort err if $? != 0
    else
      STDOUT << diff
    end
  end
end