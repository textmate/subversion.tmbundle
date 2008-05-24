#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/subversion'

Subversion.run(ARGV) { |err| STDERR << err; exit 1; }
puts Subversion.status(ARGV.last).commit_window_code_string