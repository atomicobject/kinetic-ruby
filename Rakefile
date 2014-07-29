HERE = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(HERE, 'lib')

require 'rake'
require 'rake/clean'
require 'kinetic-ruby'

load 'tasks/kinetic-ruby.rake'

CLEAN.include ['*.gem', '*.log']

desc "Run example"
task :example do
  kr = KineticRuby::Proto.new
  kr.test_kinetic_proto
end

desc "Run example w/o logging"
task :example_no_log do
  kr = KineticRuby::Proto.new(KineticRuby::Logger::LOG_LEVEL_NONE)
  kr.test_kinetic_proto
end

desc "Run example w/ verbose logging"
task :example_verbose_log do
  kr = KineticRuby::Proto.new(KineticRuby::Logger::LOG_LEVEL_VERBOSE)
  kr.test_kinetic_proto
end

task :default => [:example]

desc "Build kinetic-ruby gem"
task :build do
  banner "Building kinetic-ruby gem v#{KineticRuby::VERSION} using Kinetic Protocol #{KineticRuby::KINETIC_PROTOCOL_VERSION}"
  sh "gem build kinetic-ruby.gemspec"
  puts
end

task :release => :build do
  banner "Publishing kinetic-ruby gem v#{KineticRuby::VERSION} to RubyGems"
  proto_ver = KineticRuby::KINETIC_PROTOCOL_VERSION
  if proto_ver !~ /v\d+\.\d+\.\d+/
    raise "Can only publish gem with a release tag of Kinetic Protocol!\n" +
      "  reported Kinetic Protocol version: "
  end
  puts "Releasing gem built w/ Kinetic Protocol #{proto_ver}"
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
