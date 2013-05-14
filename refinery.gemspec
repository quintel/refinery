lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'refinery'
  gem.version       = '0.0.1'

  gem.authors       = [ 'Anthony Williams', 'Dennis Schoenmakers' ]
  gem.email         = [ 'anthony.williams@quintel.com',
                        'dennis.schoenmakers@quintel.com' ]

  gem.description   = 'Graph calculation for ETSource'
  gem.summary       = ''
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'turbine-graph', '>= 0.1'
  gem.add_dependency 'ruby-graphviz'
  gem.add_dependency 'terminal-table'

  gem.add_development_dependency 'rake', '>= 10.0.3'

end
