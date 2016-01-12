# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_record/sql_analyzer/version', __FILE__)
Gem::Specification.new do |s|
  s.authors       = ['Zachary Anker', 'Gabriel Gilder']
  s.email         = %w(zanker@squareup.com gabriel@squareup.com)
  s.description   = 'ActiveRecord query logger and analyzer'
  s.summary       = 'Logs a subset of ActiveRecord queries and dumps them for analyses.'
  s.homepage      = 'https://github.com/square/active_record-sql_analyzer'

  s.license       = 'Apache License 2.0'
  s.files         = `git ls-files`.split("\n")
  s.executables   = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = 'active_record-sql_analyzer'
  s.require_paths = ['lib']
  s.version       = ActiveRecord::SqlAnalyzer::VERSION

  s.add_dependency 'activerecord', '~> 4.0', '>= 4.0.0'

  s.add_development_dependency 'mysql2', '~> 0.4', '>= 0.4.0'
  s.add_development_dependency 'bundler', '~> 1.8'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rubocop', '~> 0.30'
  s.add_development_dependency 'timecop', '~> 0.8'
end
