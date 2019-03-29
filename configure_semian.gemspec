
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "configure_semian/version"

Gem::Specification.new do |spec|
  spec.name          = "configure_semian"
  spec.version       = ConfigureSemian::VERSION
  spec.authors       = ["supantha"]
  spec.email         = ["supantha.samanta@gmail.com"]
  spec.files         = Dir["{lib}/**/*"] + ["README.md"]
  spec.summary       = "Configure Semian"
  spec.description   = "Semian Connector"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  spec.add_dependency "rails", ">=4.0.2"
  spec.add_dependency "semian"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
