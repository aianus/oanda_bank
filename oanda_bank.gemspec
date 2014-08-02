Gem::Specification.new do |gem|
  gem.name          = 'oanda_bank'
  gem.version       = '1.0.0'
  gem.authors       = ['Alex Ianus']
  gem.email         = ['hire@alexianus.com']
  gem.description   = ['Ruby Money::Bank interface for OANDA currency rate data']
  gem.summary       = ['Ruby Money::Bank interface for OANDA currency rate data']
  gem.homepage      = 'https://github.com/aianus/oanda_bank'
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'vcr', '~> 2.9'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'webmock', '~> 1.18'
  gem.add_development_dependency 'simplecov', '~> 0.7'

  gem.add_dependency 'oauth2', '~> 1.0'
  gem.add_dependency 'money', '~> 6.0'
end
