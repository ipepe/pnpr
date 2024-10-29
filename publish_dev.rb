#!/usr/bin/env ruby

{
  "2.7.2" => ["12"],
  "3.1.4" => ["18"],
  "2.3.1" => ["10"],
}.each do |ruby_version, node_versions|
  node_versions.each do |node_version|
    image_tag = "dev-u20.04-r#{ruby_version}-n#{node_version}"
    image_name = "ipepe/pnpr:#{image_tag}"
    env_level = "production"
    friendly_error_pages = "off"

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
