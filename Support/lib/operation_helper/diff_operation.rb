#!/usr/bin/env ruby -w

location = File.dirname(__FILE__)

require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/progress"
require "#{location}/../subversion"

module Subversion
  class DiffOperation

    def initialize(base, revision, *files)
      @base = base
      @revision = revision
      if @base
        escaped_base = Regexp.escape((base =~ /\/$/) ? base : base + '/')
        @files = files.map { |f| f.sub(/^#{escaped_base}/, '') }
      else
        @files = files
      end
    end
    
    def diff
      diff_op = Proc.new do
        Dir.chdir(@base) { Subversion.run("diff", "-r", @revision, *@files) }
      end
      if @revision == 'BASE'
        diff_op.call
      else
        TextMate::call_with_progress(:title => "svn diff", :message => "Fetching diff (#{@revision})", &diff_op)
      end
    end

  end
end

if __FILE__ == $0
  STDOUT << "Enter base: "
  base = gets.chomp
  STDOUT << "Enter revision argument: "
  revision = gets.chomp
  STDOUT << "Enter description: "
  description = gets.chomp
  STDOUT << "Enter comma seperated file list: "
  files = gets.chomp.split(',')

  diffop = Subversion::DiffOperation.new(base,revision,description,*files)
  STDOUT << diffop.diff
end