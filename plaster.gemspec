# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plaster/version'

Gem::Specification.new do |spec|
  spec.name          = "plaster"
  spec.version       = Plaster::VERSION
  spec.authors       = ["Steve Jorgensen"]
  spec.email         = ["stevej@stevej.name"]

  spec.summary       = "Aids conversion of data into or out a concretely modeled " \
                       "structure for transport between software systems or " \
                       "components."
  spec.homepage      = "https://github.com/stevecj/plaster"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "activesupport", ">= 2.3"#, require: 'active_support/hash_with_indifferent_access'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "virtus", "~> 1.0.5"
end
