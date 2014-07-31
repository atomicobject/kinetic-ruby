# Preload all library files
Dir['lib/**/*.rb'].each do |f|
  require_relative(File.join(File.dirname(f), File.basename(f, '.rb')))
end

module KineticRuby
  module Rake
    def self.load_tasks
      Dir['tasks/**/*.rake'].each do |tasks|
        load tasks
      end
    end
  end
end
