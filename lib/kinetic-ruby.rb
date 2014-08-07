# Preload library files
require 'fileutils'
require 'socket'
FileUtils.cd(File.dirname(__FILE__)) do
  Dir['./**/*.rb'].each do |f|
    mod = f.sub(/.rb/, '')
    require mod
  end
end

module KineticRuby

  # Rake extensions for kinetic-ruby
  module Rake
    # Call from Rakefile to load kinetic-ruby Rake tasks (after requiring this file)
    def self.load_tasks
      Dir["#{File.dirname(__FILE__)}/../tasks/**/*.rake"].each do |tasks|
        load tasks
      end
    end

    # Autoload rake tasks if Rake already loaded
    load_tasks if defined?(Rake)
  end
end
