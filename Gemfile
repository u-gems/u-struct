# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in u-struct.gemspec
gemspec

gem 'rake', '~> 13.0'

group :test do
  gem 'minitest', '~> 5.0'
  gem 'ostruct', '~> 0.6.3' if RUBY_VERSION >= '3.5'
  gem 'simplecov', '~> 0.22.0', require: false
end

# Linting and type-checking run only on Ruby 3.1 (pinned toolchain); see
# .github/workflows/ci.yml. The pins are gated to that series so they never
# break `bundle install` on the rest of the Ruby matrix.
if RUBY_VERSION >= '3.1.0' && RUBY_VERSION < '3.2.0'
  gem 'rubocop',          '1.26'
  gem 'rubocop-minitest', '0.18.0'
  gem 'rubocop-rake',     '0.6.0'

  gem 'sorbet',  '0.5.9775'
  gem 'tapioca', '0.7.0'
end
