#!/usr/bin/env ruby

current_dir = File.expand_path(File.dirname(__FILE__))
pids = [ ]
pids << fork do
  puts "running gem specs"
  system("docker run -v #{current_dir}:/usr/src/app tawan/what-happened:latest bundle exec rspec spec")
  exit $?.exitstatus
end
pids << fork do
  puts "running integration tests for Rails 4"
  system("docker run -v #{current_dir}/integration_tests/rails_app:/usr/src/app -v #{current_dir}:/usr/src/gem tawan/what-happened:rails-4-app bundle exec rspec spec")
  exit $?.exitstatus
end

exitstatus = 0
pids.each do |pid|
  Process.wait(pid)
  exitstatus += $?.exitstatus
end

exit exitstatus
