# frozen_string_literal: true

require_relative 'lib/micro/struct/version'

Gem::Specification.new do |spec|
  spec.name          = 'u-struct'
  spec.version       = Micro::Struct::VERSION
  spec.authors       = ['Rodrigo Serradura']
  spec.email         = ['rodrigo.serradura@gmail.com']

  spec.summary       = 'Create powered Ruby structs.'
  spec.description   = 'Create powered Ruby structs.'
  spec.homepage      = 'https://github.com/serradura/u-struct'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/serradura/u-struct'
  spec.metadata['changelog_uri'] = 'https://github.com/serradura/u-struct/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency 'appraisal', '~> 2.5'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 13.0'
end
