# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_sequence/version'

Gem::Specification.new do |spec|
  spec.name          = "event_sequence"
  spec.version       = EventSequence::VERSION
  spec.authors       = ["Kirill Suhodolov"]
  spec.email         = ["kirillsuhodolov@gmail.com"]

  spec.summary       = "Implementation of event sequence with background processing instead of ActiveRecord callbacks"
  spec.description   = "Implementation of event sequence with background processing instead of ActiveRecord callbacks"
  spec.homepage      = "https://github.com/KirillSuhodolov/event_sequence"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency             'activejob', '>= 4.2.0'
  spec.add_dependency             'resque', '1.25.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
