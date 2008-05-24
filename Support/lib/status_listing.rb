require File.dirname(__FILE__) + "/subversion"
require "rexml/document"

module Subversion

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
    
    def initialize(out)
      @doc = REXML::Document.new(out)
    end
    
    def commit_window_code_string()
      codes = @doc.elements.collect("status/*/entry/wc-status") do |status| 
        status_to_commit_window_code(
          status.attributes["item"], 
          status.attributes["props"], 
          status.attributes["copied"] == "true",
          status.attributes["wc-locked"] == "true",
          status.attributes["switched"] == "true",
          status.get_elements('lock').size > 0
        )
      end
      codes.join(':')
    end
    
    def paths(base = nil)
      base = Regexp.escape(base) if base
      @doc.elements.collect("status/*/entry") do |entry| 
        path = entry.attributes["path"]
        base ? path.sub(/^#{base}/, '') : path
      end
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
  status = Subversion::StatusListing.new(STDIN.read)
  puts "commit_window_code_string: #{status.commit_window_code_string}"
  puts "Files…"
  puts status.paths
end