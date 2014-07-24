require 'rake'
require_relative 'lib/kinetic-ruby'

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
