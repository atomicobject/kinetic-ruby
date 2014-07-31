require 'rake'
require 'rake/clean'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'kinetic-ruby'

KineticRuby::Rake::load_tasks()

CLEAN.include ['*.gem', '*.log']

namespace :test do
  desc "Test Kinetic Ruby server"
  task :server => 'kinetic:server:start' do
    report "Started Kinetic Ruby server!"
    sleep 2.0
    client = Thread.new do
      report "Connecting test client to #{$kinetic_server.host}:#{$kinetic_server.port}..."
      sh "telnet #{$kinetic_server.host} #{$kinetic_server.port}"
    end
    sleep 1.0
    raise "Failed connecting a client to Kinetic Ruby server!" unless $kinetic_server.connected
    client.exit
    client.join(2.0)
    $kinetic_server.shutdown unless $kinetic_server.nil?
    $kinetic_server = nil
    sleep 2.0
    report "Kinetic Ruby server test successful!"
  end
end

desc "Run example"
task :example do
  kl = KineticRuby::Logger.new
  kr = KineticRuby::Proto.new(kl)
  kr.test_kinetic_proto
end

desc "Run example w/o logging"
task :example_no_log do
  kl = KineticRuby::Logger.new(KineticRuby::Logger::LOG_LEVEL_NONE)
  kr = KineticRuby::Proto.new(kl)
  kr.test_kinetic_proto
end

desc "Run example w/ verbose logging"
task :example_verbose_log do
  kl = KineticRuby::Logger.new(KineticRuby::Logger::LOG_LEVEL_VERBOSE)
  kr = KineticRuby::Proto.new(kl)
  kr.test_kinetic_proto
end

desc "Build kinetic-ruby gem"
task :build do
  report("Building kinetic-ruby gem v#{KineticRuby::VERSION} w/ Kinetic Protocol #{KineticRuby::Proto::PROTOCOL_VERSION}", true)
  sh "gem build kinetic-ruby.gemspec"
  report
end

task :release => :ci do
  report("Publishing kinetic-ruby gem v#{KineticRuby::VERSION} to RubyGems", true)
  proto_ver = KineticRuby::KINETIC_PROTOCOL_VERSION
  if proto_ver !~ /v\d+\.\d+\.\d+/
    raise "Can only publish gem with a release tag of Kinetic Protocol!\n" +
      "  reported Kinetic Protocol version: "
  end
  report "Releasing gem built w/ Kinetic Protocol #{proto_ver}"
  sh "gem push kinetic-ruby-#{KineticRuby::VERSION}.gem"
  report
end

task :default => [:example, 'test:server']

task :ci =>[:clobber, :example, :example_no_log, 'test:server', :build] do
  report("Kinetic Ruby Test Results", true)
  report "SUCCESSFUL!"
end

#############################################
# Helper methods and goodies

def report(msg='', banner=false)
  $stderr.flush
  if banner
    len = msg.length
    msg = "\n#{msg}\n#{'-'*len}" 
  end
  puts msg
  $stdout.flush
end
