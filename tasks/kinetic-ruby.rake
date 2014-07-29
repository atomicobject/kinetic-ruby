require 'rake'
require 'socket'
require_relative '../kinetic-ruby' unless defined? KineticRuby

namespace :server do

  desc "Start Kinetic Test Server"
  task :start, :port, :log do |t, args|
    $kinetic_server ||= KineticRuby::Server.new(args[:port], args[:log])
    $kinetic_server.start
  end

  desc "Shutdown Kinetic Test Server"
  task :shutdown do
    $kinetic_server.shutdown unless $kinetic_server.nil?
    $kinetic_server = nil
  end

end

# This block of code will be run prior to Rake instance terminating
END {
  # Ensure test server is shutdown, so we can terminate cleanly
  $kinetic_server.shutdown unless $kinetic_server.nil?
  $kinetic_server = nil
}
