require 'rake'
require 'rake/clean'
require_relative 'lib/kinetic-ruby'

CLEAN.include ['*.gem', '*.log']

desc "Run example"
task :example do
  kr = KineticRuby.new
  kr.log_level = KineticRuby::LOG_LEVEL_INFO
  kr.test_kinetic_proto
end

desc "Run example w/o logging"
task :example_no_log do
  kr = KineticRuby.new
  kr.log_level = KineticRuby::LOG_LEVEL_NONE
  kr.test_kinetic_proto
end

desc "Run example w/ verbose logging"
task :example_verbose_log do
  kr = KineticRuby.new
  kr.log_level = KineticRuby::LOG_LEVEL_VERBOSE
  kr.test_kinetic_proto
end

task :default => [:example]

desc "Build kinetic-ruby gem"
task :build do
  banner "Building kinetic-ruby gem v#{KineticRuby::VERSION}"
  sh "gem build kinetic-ruby.gemspec"
  puts
end

task :release => :build do
  banner "Publishing kinetic-ruby gem v#{KineticRuby::VERSION} to RubyGems"
  sh "gem push kinetic-ruby-#{KineticRuby::VERSION}.gem"
  puts
end

task :ci =>[:clobber, :example, :example_no_log, :build]

#############################################
# Helper methods and goodies

def banner(msg)
  puts
  puts msg
  puts "-"*msg.length
end
