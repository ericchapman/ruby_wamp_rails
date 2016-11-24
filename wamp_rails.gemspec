# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wamp_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "wamp_rails"
  spec.version       = WampRails::VERSION
  spec.authors       = ['Eric Chapman']
  spec.email         = ['eric.chappy@gmail.com']
  spec.summary       = %q{Web Application Messaging Protocol Client for Rails}
  spec.description   = %q{An implementation of The Web Application Messaging Protocol (WAMP)}
  spec.homepage      = 'https://github.com/ericchapman/ruby_wamp_rails'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codecov'

  spec.add_dependency 'wamp_client', '~> 0.0.7'
end
