# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paysafe/version'

Gem::Specification.new do |spec|
  spec.name          = "paysafe"
  spec.version       = Paysafe::VERSION
  spec.authors       = ["Javier Julio"]
  spec.email         = ["javier@jackpocket.com"]

  spec.summary       = "A Ruby interface to the Paysafe REST API."
  spec.description   = "A Ruby interface to the Paysafe REST API."
  spec.homepage      = "https://github.com/jackpocket/paysafe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency "http", '>= 4', '< 6'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "minitest-mock_expectations"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
