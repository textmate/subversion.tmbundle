#!/usr/bin/env ruby

require 'pathname'
require File.dirname(__FILE__) + '/../lib/subversion'

file = ARGV.last

out = Subversion.run(ARGV) { |err| puts err; exit 1; }
status = Subversion.status(file)
puts status.commit_window_code_string + " " + file