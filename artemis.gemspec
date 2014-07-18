# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capybara/artemis/version'

Gem::Specification.new do |spec|
  spec.name          = "artemis"
  spec.version       = Artemis::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Ben Pritchard"]
  spec.email         = ["bpritchard@westfield.com"]
  spec.summary       = 'A basic GET-only Net::HTTP driver for Capybara'
  spec.description   = 'Artemis is a Capybara driver for testing remote urls '\
                       'quickly with Net::HTTP when you don\'t need to interact '\
                       'with the DOM just read it'
  spec.homepage      = "http://github.com/benpritchard/artemis"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = Dir.glob('{lib}/**/*') + %w(LICENSE.txt README.md)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'capybara',         '~> 2.2'
end