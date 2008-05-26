require File.dirname(__FILE__) + "/subversion"
require "rexml/document"
require 'time'

module Subversion

  class XmlStatusParser

    def initialize(xml)
      @targets = []
      REXML::Document.parse_stream(xml, self)
    end

    def xmldecl(*ignored)
    end

    def tag_start(name, attributes)
      case name
      when 'target'
        @target = {'entries' => []}.merge! attributes
      when 'entry'
        @entry = attributes.dup
      when 'wc-status'
        @wc_status = attributes.dup
      when 'commit'
        @commit = attributes.dup
      when 'lock'
        @lock = {}
      end
    end

    def tag_end(name)
      case name
      when 'target'
        @targets << @target
      when 'entry'
        @target['entries'] << @entry
      when 'wc-status'
        @entry['wc-status'] = @wc_status
      when 'author', 'date'
        @commit[name] = (name == 'date') ? Time.xmlschema(@text) : @text
      when 'commit'
        @wc_status[name] = @commit
      when 'token', 'owner', 'created'
        @lock[name] = (name == 'created') ? Time.xmlschema(@text) : @text
      when 'lock'
        @wc_status[name] = @lock
      end
    end

    def text(text)
      @text = text
    end

    def status
      Subversion::StatusListing.new(@targets)
    end
  end

  class StatusListing

    @@status_code_mapping = {
      "none" => "",
      "normal" => "",
      "modified" => "M",
      "added" => "A",
      "deleted" => "D",
      "conflicted" => "C",
      "unversioned" => "?",
      "external" => "X",
      "ignored" => "I",
      "incomplete" => "!",
      "missing" => "!",
      "obstructed" => '~',
      "replaced" => 'R',
      "unversioned" => '?'
    }
    @@status_code_mapping.default = ""
    
    def initialize(targets)
      @targets = targets
    end
    
    def commit_window_code_string()
      codes = @targets.collect do |target|
        target['entries'].collect do |entry|
          status = entry['wc-status']
          status_to_commit_window_code(
            status["item"], 
            status["props"], 
            status["copied"] == "true",
            status["wc-locked"] == "true",
            status["switched"] == "true",
            !status['lock'].nil?
          )
        end
      end
      codes.flatten.join(':')
    end
    
    def paths(base = nil)
      base = Regexp.escape(base) if base
      paths = @targets.collect do |target|
        target['entries'].collect do |entry|
          path = entry["path"]
          base ? path.sub(/^#{base}/, '') : path
        end
      end
      paths.flatten
    end
    
    def status_to_commit_window_code(item, props, copied, wc_locked, switched, lock)
      [
        @@status_code_mapping[item],
        @@status_code_mapping[props],
        (copied) ? "+" : "",
        (wc_locked) ? "L" : "",
        (switched) ? "S" : "",
        (lock) ? "K" : ""
      ].join('')
    end
  end
end

if __FILE__ == $0
  status = Subversion::XmlStatusParser.new(STDIN.read).status
  puts "commit_window_code_string: #{status.commit_window_code_string}"
  puts "Files…"
  puts status.paths
end