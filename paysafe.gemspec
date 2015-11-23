# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paysafe/version'

Gem::Specification.new do |spec|
  spec.name          = "paysafe"
  spec.version       = Paysafe::VERSION
  spec.authors       = ["Javier Julio"]
  spec.email         = ["jjfutbol@gmail.com"]

  spec.summary       = %q{Gem to wrap Paysafe REST API}
  spec.description   = %q{Gem to wrap Paysafe REST API}
  spec.homepage      = "https://github.com/javierjulio/paysafe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"

  spec.add_dependency "http", '~> 0.9.8'

end
