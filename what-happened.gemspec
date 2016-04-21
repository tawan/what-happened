# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'what_happened/version'

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = 'what_happened'
  spec.version       = WhatHappened.version
  spec.authors       = ['Tawan Sierek']
  spec.email         = ['tawan@sierek.com']
  spec.description   = ''
  spec.summary       = spec.description
  spec.license       = 'MIT'
  spec.homepage      = 'https://github.com/tawan/what-happened'

  spec.files         = Dir.glob('lib/**/*') + [ 'what-happened.gemspec' ]
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'rails', '~> 4.2'
end
