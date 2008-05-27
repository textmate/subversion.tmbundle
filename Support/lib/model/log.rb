require "rexml/document"
require 'time'

module Subversion

  class XmlLogParser
    def initialize(xml)
      @entries = []
      REXML::Document.parse_stream(xml, self)
    end

    def xmldecl(*ignored)
    end

    def tag_start(name, attributes)
      case name
      when 'logentry'
        @current_entry = {"rev" => attributes['revision'].to_i}
      when 'paths'
        @current_paths = {}
      when 'path'
        @current_action = attributes['action']
      end
    end

    def tag_end(name)
      case name
      when 'author','msg'
        @current_entry[name] = @tag_text
      when 'date'
        @current_entry[name] = Time.xmlschema(@tag_text)
      when 'logentry'
        @entries.push @current_entry
      when 'paths'
        @current_entry['paths'] = @current_paths
      when 'path'
        @current_paths[@tag_text] = @current_action
      end
    end

    def text(text)
      @tag_text = text
    end
    
    def log
      Subversion::Log.new(@entries)
    end
  end
  
  class Log
    attr_reader :entries

    def initialize(entries)
      @entries = entries
    end

    def revisions
      @entries.collect { |entry| entry["rev"] }
    end
  end
end

if __FILE__ == $0
  log = Subversion::XmlLogParser.new(STDIN.read).log
  puts "revisions: #{log.revisions.join(',')}"
  p log
end