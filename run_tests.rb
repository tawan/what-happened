#!/usr/bin/env ruby

current_dir = File.expand_path(File.dirname(__FILE__))
system("docker run -v #{current_dir}:/usr/src/app tawan/what-happened:latest bundle exec rspec spec")
exitstatus = $?.exitstatus > 0 ? $?.exitstatus : 0
system("docker run -v #{current_dir}/integration_tests/rails_app:/usr/src/app -v #{current_dir}:/usr/src/gem tawan/what-happened:rails-4-app bundle exec rspec spec")
if  exitstatus > 0
  exit exitstatus
else
  exit $?.exitstatus
end
