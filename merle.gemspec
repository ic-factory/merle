# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "merle/version"

Gem::Specification.new do |spec|
  spec.name          = "merle"
  spec.version       = Merle::VERSION
  spec.authors       = ["Torben Fox Jacobsen"]
  spec.email         = ["ecic@ic-factory.com"]
  spec.licenses       = ['LGPL-3.0']
  spec.summary       = "Reads VHDL files and outputs GNU Make dependencies files"
  spec.description   = "This gem can read VHDL files and generate GNU Make dependency files that can be used during compilation. It also includes functions to generate eg. a Make formatted list of libraries and source lists within an ECIC project."
  spec.homepage      = "https://github.com/ic-factory/merle"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions    = %w[ext/mytest/extconf.rb]

  spec.required_ruby_version = '>= 2.4.4'
  spec.add_dependency "thor", '~> 0.20'
  spec.add_dependency "colorize", '~> 0.8'
  spec.add_dependency "rake", '~> 12.3'
  spec.add_dependency "activesupport", '~> 5.2'
  spec.add_dependency "ecic", "~> 0.6.2"

  spec.add_development_dependency "bundler", '~> 1.16'
  spec.add_development_dependency "byebug", '~> 10.0'
  spec.add_development_dependency "rspec", '~> 3.8'
end
