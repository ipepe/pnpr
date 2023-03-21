#!/usr/bin/env ruby
RUBY_VERSIONS = [
  "2.3.1", "2.3.8",
  "2.4.10",
  "2.5.9",
  "2.6.10",
  "2.7.2", "2.7.5", "2.7.6", "2.7.7",
  "3.0.4", "3.0.5",
  "3.1.2", "3.1.3"
].freeze

NODE_VERSIONS = ["10", "12", "14", "16", "18"].freeze

NODE_VERSIONS.each do |node_version|
  RUBY_VERSIONS.each do |ruby_version|
    image_tag = "v3.2-u20.04-r#{ruby_version}-n#{node_version}"
    image_name = "ipepe/pnpr:#{image_tag}"
    env_level = "production"
    friendly_error_pages =
      if env_level == "production"
        "off"
      else
        "on"
      end
    puts "Building #{image_name}"
    `docker build . --tag "#{image_name}" \
            --cache-from docker.io/#{image_name} \
            --build-arg RUBY_VERSION=#{ruby_version} \
            --build-arg NODE_MAJOR_VERSION=#{node_version} \
            --build-arg RAILS_ENV=#{env_level} \
            --build-arg NODE_ENV=#{env_level} \
            --build-arg FRIENDLY_ERROR_PAGES=#{friendly_error_pages}`
    puts "Pushing #{image_name}"
    `docker push "#{image_name}"`
  end
end
