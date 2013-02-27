# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Paul Barry"]
  gem.email         = ["mail@paulbarry.com"]
  gem.description   = %q{A simple router for Rack apps}
  gem.summary       = %q{A simple router for Rack apps}
  gem.homepage      = "https://github.com/pjb3/rack-router"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-router"
  gem.require_paths = ["lib"]
  gem.version       = "0.3.0"
end
