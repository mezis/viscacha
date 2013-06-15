# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lmc/store/version'

Gem::Specification.new do |spec|
  spec.name          = "lmc-store"
  spec.version       = Lmc::Store::VERSION
  spec.authors       = ["Julien Letessier"]
  spec.email         = ["julien.letessier@gmail.com"]
  spec.description   = %q{Shared memory cache for ActiveSupport, leveraging the localmemcache gem.}
  spec.summary       = %q{Shared memory cache for ActiveSupport}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "localmemcache", "~> 0.4.0"
  spec.add_dependency "activesupport"
end
