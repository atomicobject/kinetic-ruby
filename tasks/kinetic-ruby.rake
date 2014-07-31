require 'rake'
require_relative '../kinetic-ruby' unless defined? KineticRuby

namespace :kinetic do
  namespace :server do

    desc "Start Kinetic Test Server"
    task :start, :port, :log do |t, args|
      if args[:port]
        if args[:log]
          $kinetic_server ||= KineticRuby::Server.new(args[:port], args[:log])
        else
          $kinetic_server ||= KineticRuby::Server.new(args[:port])
        end
      else
        $kinetic_server ||= KineticRuby::Server.new
      end
      $kinetic_server.start
      sleep 2.0
    end

    desc "Shutdown Kinetic Test Server"
    task :shutdown do
      $kinetic_server.shutdown unless $kinetic_server.nil?
      $kinetic_server = nil
    end

  end
end

# This block of code will be run prior to Rake instance terminating
END {
  # Ensure test server is shutdown, so we can terminate cleanly
  $kinetic_server.shutdown unless $kinetic_server.nil?
  $kinetic_server = nil
}
