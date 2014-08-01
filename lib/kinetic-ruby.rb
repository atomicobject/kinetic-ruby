# Preload all library files
require 'fileutils'

FileUtils.cd(File.dirname(__FILE__)) do
  Dir['./**/*.rb'].each do |f|
    mod = f.sub(/.rb/, '')
    require mod
  end
end

module KineticRuby
  module Rake
    def self.load_tasks
      Dir["#{File.dirname(__FILE__)}/../tasks/**/*.rake"].each do |tasks|
        load tasks
      end
    end
  end
end
