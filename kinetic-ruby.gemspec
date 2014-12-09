# -*- encoding: utf-8 -*-
HERE = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH << File.join(HERE, 'lib')
require 'version.rb'
require 'date'

Gem::Specification.new do |s|
  s.name = 'kinetic-ruby'
  s.version = KineticRuby::VERSION
  s.platform = Gem::Platform::RUBY
  s.licenses = ['LGPL-2.1']
  s.authors = ['Greg Williams']
  s.email = ['greg.williams@atomicobject.com']
  s.homepage = 'http://github.com/atomicobject/kinetic-ruby'
  s.date = Date.today.to_s
  s.description = 'Seagate Kinetic Protocol implementation and examples for developing Kinetic clients in Ruby'
  s.summary = "Seagate Kinetic Protocol library for Ruby using Kinetic Protocol #{KineticRuby::PROTOCOL_VERSION}"

  s.add_dependency 'rake', '>= 0.9.2.2'
  s.add_dependency 'beefcake'
  s.add_dependency 'rspec'
  
  s.files = ['README.md', 'Rakefile', 'LICENSE'] + Dir['lib/**/*'] + Dir['tasks/**/*'] + Dir['vendor/kinetic-protocol/**/*']
  #s.test_files = [] # NEED SOME!!
  s.require_paths = ['lib', 'lib/protobuf']
end
