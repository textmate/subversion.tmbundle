require "rexml/document"
require 'ostruct'
require 'time'

module Subversion

  class Log

    class ParseListener

      attr_reader :entries

      def initialize
        @entries = []
        @current = nil
      end

      def xmldecl(*ignored)
      end

      def tag_start(name, attributes)
        case name
        when 'logentry'
          @current = {"rev" => attributes['revision'].to_i}
        end
      end

      def tag_end(name)
        case name
        when 'author','msg'
          @current[name] = @text
        when 'date'
          @current[name] = Time.xmlschema(@text)
        when 'logentry'
          @entries.push @current
        end
      end

      def text(text)
        @text = text
      end
    end

    attr_reader :entries

    def initialize(log)
      listener = ParseListener.new
      REXML::Document.parse_stream(log, listener)
      @entries = listener.entries
    end

    def revisions()
      @entries.collect { |entry| entry["rev"] }
    end
  end
end

if __FILE__ == $0
  log = Subversion::Log.new(STDIN.read)
  puts "revisions: #{log.revisions.join(',')}"
  puts log.entries.inspect
end