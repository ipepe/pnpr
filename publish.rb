#!/usr/bin/env ruby
# frozen_string_literal: true

RUBY_VERSIONS = %w[
  2.1.0 2.1.1 2.1.2 2.1.3 2.1.4 2.1.5 2.1.6 2.1.7 2.1.8 2.1.9 2.1.10
  2.2.0 2.2.1 2.2.2 2.2.3 2.2.4 2.2.5 2.2.6 2.2.7 2.2.8 2.2.9 2.2.10
  2.3.0 2.3.1 2.3.2 2.3.3 2.3.4 2.3.5 2.3.6 2.3.7 2.3.8
  2.4.0 2.4.1 2.4.2 2.4.3 2.4.4 2.4.5 2.4.6 2.4.7 2.4.8 2.4.9 2.4.10
  2.5.0 2.5.1 2.5.2 2.5.3 2.5.4 2.5.5 2.5.6 2.5.7 2.5.8 2.5.9
  2.6.0 2.6.1 2.6.2 2.6.3 2.6.4 2.6.5 2.6.6 2.6.7 2.6.8 2.6.9 2.6.10
  2.7.0 2.7.1 2.7.2 2.7.3 2.7.4 2.7.5 2.7.6 2.7.7
  3.0.0 3.0.1 3.0.2 3.0.3 3.0.4 3.0.5
  3.1.0 3.1.1 3.1.2 3.1.3
].freeze

NODE_VERSIONS = %w[10 12 14 16 18].freeze

ENV_LEVELS = %w[development production staging].freeze

RUBY_VERSIONS.each do |ruby_version|
  NODE_VERSIONS.each do |node_version|
    ENV_LEVELS.each do |env_level|
      image_tag = "v3-u2004-r#{ruby_version}-n#{node_version}-#{env_level}"
      image_name = "ipepe/pnpr:#{image_tag}"
      friendly_error_pages =
        if env_level == 'production'
          'on'
        else
          'off'
        end
      puts "Building #{image_name}"
      `docker build . -t "#{image_name}" \
            --build-arg RUBY_VERSION=#{ruby_version} \
            --build-arg NODE_MAJOR_VERSION=#{node_version} \
            --build-arg RAILS_ENV=#{env_level} \
            --build-arg NODE_ENV=#{env_level} \
            --build-arg FRIENDLY_ERROR_PAGES=#{friendly_error_pages}`
      puts "Pushing #{image_name}"
      `docker push "#{image_name}"`
    end
  end
end
