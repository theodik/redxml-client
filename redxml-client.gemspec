# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redxml/client/version'

Gem::Specification.new do |spec|
  spec.name          = "redxml-client"
  spec.version       = RedXML::Client::VERSION
  spec.authors       = ["Ondřej Svoboda"]
  spec.email         = ["theodik@gmail.com"]
  spec.summary       = "redxml-client-#{RedXML::Client::VERSION}"
  spec.description   = 'Client for RedXML database'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'coveralls'
end
