#!/usr/bin/env ruby

require 'optparse'
require File.dirname(__FILE__) + "/../lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/process"

revision = 'HEAD'
send_to_mate = false

optparser = OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename(__FILE__)} [options] [url]"
  optparser.separator ""
  optparser.separator "Specific options:"
  
  optparser.on("--send-to-mate", "If present, the file will be opened with `mate` instead of sent to STDOUT") do |s|
    send_to_mate = s
  end

  optparser.on("--revision=REVISION", "") do |r|
    revision = r
  end

end

optparser.parse!
url = ARGV.first
content = Subversion.cat(url, revision)
  
if send_to_mate
  tmp = File.new((ENV['TMPDIR'] || '/tmp') + "/" + File.basename(url), "w")
  tmp.write content
  tmp.flush
  out, err = TextMate::Process.run("mate", "-w", tmp.path)
  abort err if $? != 0
else
  $stdout << content
end