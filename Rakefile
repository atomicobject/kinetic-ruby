require 'rake'
require 'rake/clean'
$LOAD_PATH.unshift File.expand_path('lib')
require 'kinetic-ruby'

KineticRuby::Rake::load_tasks()

CLEAN.include ['*.gem', '*.log']

namespace :test do
  desc "Test Kinetic Ruby server"
  task :server => 'kinetic:server:start' do

    report("Validating server can accept a client connection", true)

    report "Kinetic Ruby server launched!"

    client = Thread.new do
      addr = $kinetic_server.host + ':' + $kinetic_server.port.to_s
      report "Connecting test client to #{addr}\n"
      client = TCPSocket.new('localhost', KineticRuby::DEFAULT_KINETIC_PORT)
      raise "Failed connecting to server!" unless client
      report "Connected to server!"
      client.close
    end

    report "Terminating client connection..."
    client.join 5.0

    report "Initiating server shutdown..."
    $kinetic_server.shutdown unless $kinetic_server.nil?
    $kinetic_server = nil

    report "Shutdown complete!"

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

task :update_version_info do
  require 'erb'
  proto_ver = ''
  FileUtils.cd 'vendor/kinetic-protocol' do
    proto_ver = 'v' + `git describe --tags 2> /dev/null`.strip
    proto_ver = 'v<Unknown!>' if proto_ver !~ /^v\d+\.\d+\.\d+/
  end
  template = File.read('lib/version.rb.erb')
  content = ERB.new(template).result(binding)
  File.open('lib/version.rb', "w+"){|f| f.write(content) }
  new_ver = content.match(/  VERSION = '(.+)'.+ PROTOCOL_VERSION = '(.+)'/m)
  raise "Failed to parse updated version info!" unless new_ver
  if ((new_ver[1] != KineticRuby::VERSION) ||
      (new_ver[2] != KineticRuby::PROTOCOL_VERSION))
    report "Kinetic Ruby version info has changed! You must re-run Rake to resync!\nExiting..."
    exit 1
  end
end

desc "Build kinetic-ruby gem"
task :build => :update_version_info do
  report("Building kinetic-ruby gem v#{KineticRuby::VERSION} w/ Kinetic Protocol #{KineticRuby::PROTOCOL_VERSION}", true)
  sh "gem build kinetic-ruby.gemspec"
  report
end

# desc "Build and install kinetic-ruby gem"
task :install => :ci do
  report("Installing KineticRuby gem v#{KineticRuby::VERSION}", true)
  sh "sudo gem uninstall --all kinetic-ruby"
  sh "sudo gem install --no-doc kinetic-ruby-#{KineticRuby::VERSION}.gem"
end

task :release => :ci do
  report("Publishing kinetic-ruby gem v#{KineticRuby::VERSION} to RubyGems", true)
  proto_ver = KineticRuby::PROTOCOL_VERSION
  if proto_ver !~ /v\d+\.\d+\.\d+/
    raise "Can only publish gem with a release tag of Kinetic Protocol!\n" +
      "  reported Kinetic Protocol version: "
  end
  report "Releasing gem built w/ Kinetic Protocol #{proto_ver}"
  sh "gem push kinetic-ruby-#{KineticRuby::VERSION}.gem"
  report
end

task :default => [:ci]

task :ci =>[:clobber, :example, :example_no_log, 'test:server', :build] do
  report("Kinetic Ruby Test Results", true)
  report "SUCCESSFUL!"
end

#############################################
# Helper methods and goodies

def report(msg='', banner=false)
  $stderr.flush
  $stdout.flush
  if banner
    len = msg.length
    msg = "\n#{msg}\n#{'-'*len}" 
  end
  puts msg
  $stdout.flush
end
