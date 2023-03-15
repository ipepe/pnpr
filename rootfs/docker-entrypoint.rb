#!/usr/bin/env ruby

# this script has 3 purposes:
# 1. prepare container (file permissions, etc) and start all relevant services in proper order
# 2. when receiving interrupt, forward this interrupt to all child processes
# 3. reap all zombie/defunct processes

def logged_system_call(command)
  puts "Executing: #{command}"
  system(command)
end

# ==== PREPARE CONTAINER AND START SERVICES ====
SERVICE_NAMES = [:ssh, :redis, :cron, :nginx, :"passenger-exporter", :sidekiq].freeze

logged_system_call("bash /bootstrap.sh")
logged_system_call('chown -R webapp:webapp "/home/webapp"')

SERVICE_NAMES.each do |service_name|
  logged_system_call("service #{service_name} start")
end

puts "All services started. Application is ready. Waiting for interrupt..."

# ==== RECEIVE AND FORWARD INTERRUPT SIGNALS TO CHILD PROCESSES ====
[:INT, :QUIT, :TERM].each do |signal|
  Signal.trap(signal) do
    puts "Received #{signal}"
    SERVICE_NAMES.reverse.each do |service_name|
      puts "Stopping #{service_name}"
      logged_system_call("service #{service_name} stop")
    end
    exit(Signal.list[signal.to_s])
  end
end

# ==== REAP ALL ZOMBIE AND DEFUNCT SERVICES ====
Process.waitall
exit(1)
