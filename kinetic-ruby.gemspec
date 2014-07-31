# -*- encoding: utf-8 -*-
HERE = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(HERE)

require 'kinetic-ruby'
require 'date'

Gem::Specification.new do |s|
  s.name = %q{kinetic-ruby}
  s.version = KineticRuby::VERSION
  s.license = "LGPL-2.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Greg Williams"]
  s.date = Date.today.to_s
  s.description = %q{Seagate Kinetic Protocol implementation and examples for developing Kinetic clients in Ruby}
  s.email = %q{greg.williams@atomicobject.com}
  s.files = [
    "README.md",
    "Rakefile",
    "LICENSE",
  ] + Dir["./lib/**/*"] + Dir["./tasks/**/*"] + Dir["./vendor/kinetic-protocol/*"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/atomicobject/kinetic-ruby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "tasks"]
  s.rubygems_version = %q{1.3.1}
  s.summary = "Seagate Kinetic Protocol library for Ruby using Kinetic Protocol #{KineticRuby::Proto::PROTOCOL_VERSION}"
  s.test_files = [
    # NEED SOME!!!
  ]
  s.add_runtime_dependency 'rake', '>= 0.9.2.2'
  s.add_runtime_dependency 'beefcake'
  s.add_runtime_dependency 'rspec'

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  end
end
