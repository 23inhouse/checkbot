# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkbot/version'

Gem::Specification.new do |spec|
  spec.name          = "checkbot"
  spec.version       = Checkbot::VERSION
  spec.authors       = ["Benjamin Lewis"]
  spec.email         = ["23inhouse@gmail.com"]
  spec.summary       = %q{Discounting algorithm for shopping carts}
  spec.description   = %q{Discounting algorithm for shopping carts}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
