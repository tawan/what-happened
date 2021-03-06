#!/usr/bin/env ruby
versions = %w(2.0 2.1 2.2 2.3)

versions.each do |version|
  system "rm Dockerfile" if File.exists?('Dockerfile')
  begin
  dockerfile =  File.read('Dockerfile.templ').sub(/FROM ruby:(.+)$/, "FROM ruby:#{version}")
  File.open('Dockerfile', 'w') { |file| file.write(dockerfile) }
  system "docker build -t tawan/what-happened:ruby-#{version} ."
  system "docker push tawan/what-happened:ruby-#{version}"
  ensure
    system "rm Dockerfile" if File.exists?('Dockerfile')
  end
end
