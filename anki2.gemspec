# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'anki2/version'

Gem::Specification.new do |spec|
  spec.name          = 'anki2'
  spec.version       = Anki2::VERSION
  spec.authors       = ['Albert Zak']
  spec.email         = ['me@albertzak.com']

  spec.summary       = 'Create Anki Flashcards with Ruby! Supports images, audio, HTML and CSS.'
  spec.description   = 'Create Anki Flashcards with Ruby! Supports images, audio, HTML and CSS. Build multimedia *.apkg Flashcards for use with the Anki (http://ankisrs.net) Spaced Repetition Software (SRS)'
  spec.homepage      = 'https://github.com/albertzak/anki2'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_runtime_dependency 'sqlite3', '~> 1.3.3'
  spec.add_runtime_dependency 'rubyzip', '~> 1.1.7'
end
