# -*- encoding: utf-8 -*-
require File.expand_path('../lib/opssh/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Oliver Grimm"]
  gem.email         = ["olly@pixelpogo.de"]
  gem.description   = %q{Opssh is a tiny tool, that utilizes the AWS Opsworks API to gather information, about stacks and their instances, required to start a SSH session on a single AWS EC2 instance.}
  gem.summary       = %q{ssh to your Opsworks/EC2 instances easily}
  gem.homepage      = "https://github.com/pixelpogo/opssh"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "opssh"
  gem.require_paths = ["lib"]
  gem.version       = Opssh::VERSION

  gem.add_runtime_dependency "json"
  gem.add_runtime_dependency "highline"
  gem.add_runtime_dependency "aws-sdk", '>= 1.8.3'

  gem.add_development_dependency "rspec"

end
