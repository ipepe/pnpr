#!/usr/bin/env ruby
RUBY_VERSIONS = [
  "2.3.1", "3.1.4"
].freeze

NODE_VERSIONS = ["10", "18"].freeze

NODE_VERSIONS.each do |node_version|
  RUBY_VERSIONS.each do |ruby_version|
    image_tag = "dev-u20.04-r#{ruby_version}-n#{node_version}"
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
            --build-arg RUBY_VERSION=#{ruby_version} \
            --build-arg NODE_MAJOR_VERSION=#{node_version} \
            --build-arg RAILS_ENV=#{env_level} \
            --build-arg NODE_ENV=#{env_level} \
            --build-arg FRIENDLY_ERROR_PAGES=#{friendly_error_pages}`
    puts "Pushing #{image_name}"
    `docker push "#{image_name}"`
  end
end
