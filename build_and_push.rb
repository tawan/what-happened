#!/usr/bin/env ruby
versions = %w(2.2 2.3)

def build_test_base(version)
  system "rm Dockerfile" if File.exists?('Dockerfile')
  begin
    dockerfile =  File.read('Dockerfile.templ').sub(/FROM tawan\/what-happened:ruby-(.+)$/, "FROM tawan\/what-happened:ruby-#{version}")
  File.open('Dockerfile', 'w') { |file| file.write(dockerfile) }
  image_name = "tawan/what-happened:test-base-ruby-#{version}" 
  system "docker build -t #{image_name} ."
  system "docker push #{image_name}"
  ensure
    system "rm Dockerfile" if File.exists?('Dockerfile')
  end
end

def build_rails_4_base(version)
  system "rm Dockerfile" if File.exists?('Dockerfile')
  begin
    dockerfile =  File.read('Dockerfile.rails-4-app.templ').sub(/FROM tawan\/what-happened:ruby-(.+)$/, "FROM tawan\/what-happened:ruby-#{version}")
  File.open('Dockerfile', 'w') { |file| file.write(dockerfile) }
  image_name = "tawan/what-happened:rails-4-app-ruby-#{version}" 
  system "docker build -t #{image_name} ."
  system "docker push #{image_name}"
  ensure
    system "rm Dockerfile" if File.exists?('Dockerfile')
  end
end
versions.each do |version|
 # build_test_base(version)
  build_rails_4_base(version)
end
