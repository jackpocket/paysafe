require_relative "lib/paysafe/version"

Gem::Specification.new do |spec|
  spec.name = "paysafe"
  spec.version = Paysafe::VERSION
  spec.authors = ["Javier Julio"]
  spec.email = ["javier@jackpocket.com"]

  spec.summary = "A Ruby interface to the Paysafe REST API."
  spec.description = "A Ruby interface to the Paysafe REST API."
  spec.homepage = "https://github.com/jackpocket/paysafe"
  spec.license = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency "http", '>= 4', '< 6'
end
