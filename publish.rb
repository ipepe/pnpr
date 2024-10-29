#!/usr/bin/env ruby

{
  "3.3.5" => ["10", "16", "18", "20"],
  "3.2.5" => ["10", "16", "18", "20"],
  "3.1.6" => ["10", "16", "18", "20"],
  "3.0.7" => ["10", "16", "18", "20"],
#  "2.7.8" => ["10", "12", "14", "16", "18"],
#  "2.6.10" => ["10", "12", "14", "16", "18"],
#  "2.5.9" => ["10", "12", "14", "16", "18"],
#  "2.4.10" => ["10", "12", "14", "16", "18"],
#  "2.3.8" => ["10", "12", "14", "16", "18"],
#  "2.3.1" => ["10", "12", "14", "16", "18"],
}.each do |ruby_version, node_versions|
  node_versions.each do |node_version|
    image_tag = "v3.3-u20.04-r#{ruby_version}-n#{node_version}"
    image_name = "ipepe/pnpr:#{image_tag}"
    env_level = "production"
    friendly_error_pages =
      if env_level == "production"
        "off"
      else
        "on"
      end
    puts "Building #{image_name}"
    `docker buildx build --platform=linux/amd64,linux/arm64 --push --tag "#{image_name}" . \
            --build-arg RUBY_VERSION=#{ruby_version} \
            --build-arg NODE_MAJOR_VERSION=#{node_version} \
            --build-arg RAILS_ENV=#{env_level} \
            --build-arg NODE_ENV=#{env_level} \
            --build-arg FRIENDLY_ERROR_PAGES=#{friendly_error_pages}`
  end
end
