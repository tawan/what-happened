#!/usr/bin/env ruby
require 'tempfile'

current_dir = File.expand_path(File.dirname(__FILE__))
pids = [ ]
ruby_versions = %w(2.0 2.1 2.2 2.3)
output_files = [ ]
ruby_versions.each do |ruby_version|
  output_file = Tempfile.new("output_specs_#{ruby_version}")
  pids << fork do
    puts "running specs against Ruby #{ruby_version}"
    File.open(output_file.path, 'w') { |file| file.write("running specs against Ruby #{ruby_version}\n") }
    system("docker run -v #{current_dir}:/usr/src/app tawan/what-happened:test-base-ruby-#{ruby_version} bundle exec rspec spec >> #{output_file.path} 2>&1")
    exit $?.exitstatus
  end
  output_files << output_file

  output_file = Tempfile.new("output_rails_4_#{ruby_version}")
  pids << fork do
    puts "running integration tests for Rails 4 with Ruby #{ruby_version}"
    File.open(output_file.path, 'w') { |file| file.write("running integration tests for Rails 4 with Ruby #{ruby_version}\n") }
    system("docker run -v #{current_dir}/integration_tests/rails_app:/usr/src/app -v #{current_dir}:/usr/src/gem tawan/what-happened:rails-4-app-ruby-#{ruby_version} bundle exec rspec spec >> #{output_file.path} 2>&1")
    exit $?.exitstatus
  end
  output_files << output_file
end

exitstatus = 0
pids.each do |pid|
  Process.wait(pid)
  exitstatus += $?.exitstatus
end

output_files.each do |f|
  puts File.read(f.path)
end
if exitstatus == 0
  puts "All tests passed!"
else
  puts "Some tests did not pass"
end
exit exitstatus
