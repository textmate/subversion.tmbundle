require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"

unless ARGV.empty?
  STDOUT << Subversion.run("add", ARGV)
end
