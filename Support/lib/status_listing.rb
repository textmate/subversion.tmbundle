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
      "unversioned" => "?"
    }
    @@status_code_mapping.default = "K"
    
    def initialize(out)
      @doc = REXML::Document.new(out)
    end
    
    def commit_window_code_string()
      codes = @doc.elements.collect("status/*/entry/wc-status") do |status| 
        status_to_commit_window_code(status.attributes["item"], status.attributes["props"], status.attributes["copied"])
      end
      codes.join(':')
    end
    
    def paths
      @doc.elements.collect("status/*/entry") { |entry| entry.attributes["path"] }
    end
    
    def status_to_commit_window_code(item,props,copied)
      @@status_code_mapping[item] + @@status_code_mapping[props] + ((copied == "true") ? "+" : "" )
    end
  end
end

if __FILE__ == $0
  status = Subversion::StatusListing.new(STDIN.read)
  puts "commit_window_code_string: #{status.commit_window_code_string}"
  puts "Files…"
  puts status.paths
end