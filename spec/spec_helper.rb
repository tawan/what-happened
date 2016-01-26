require 'bundler/setup'
Bundler.setup

require 'what_happened'
require 'byebug'

RSpec.configure do |config|
  config.filter_run_excluding slow: true if ENV['SPEC_ALL'] != 'true'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
