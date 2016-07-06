#!/usr/bin/env ruby
require 'tempfile'

current_dir = File.expand_path(File.dirname(__FILE__))
ruby_versions = %w(2.0 2.1 2.2 2.3)

succesfull = true
ruby_versions.each do |ruby_version|
  puts "running specs against Ruby #{ruby_version}"
  docker_run_command = "docker run -v #{current_dir}:/usr/src/app tawan/what-happened:test-base-ruby-#{ruby_version} bundle exec rspec spec"
  succesfull = system(docker_run_command) && succesfull

  puts "running integration tests for Rails 4 with Ruby #{ruby_version}"
  docker_run_command = "docker run -v #{current_dir}/integration_tests/rails_app:/usr/src/app -v #{current_dir}:/usr/src/gem tawan/what-happened:rails-4-app-ruby-#{ruby_version} bundle exec rspec spec"
  succesfull = system(docker_run_command) && succesfull
end

if succesfull
  puts "All tests passed!"
  exit 0
else
  puts "Some tests failed"
  exit 1
end
