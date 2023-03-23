#!/usr/bin/env ruby

# this script has 3 purposes:
# 1. when receiving interrupt, forward this interrupt to all child processes
# 2. prepare container (file permissions, etc) and start all relevant services in proper order
# 3. reap all zombie/defunct processes

def log(message)
  puts($PROGRAM_NAME = "[PNPR] #{message}")
end

def logged_system_call(command)
  log("Executing: #{command}")
  system(command)
end

# ==== RECEIVE AND FORWARD INTERRUPT SIGNALS TO CHILD PROCESSES ====
[:INT, :QUIT, :TERM].each do |signal|
  Signal.trap(signal) do
    log "Received #{signal}"
    SERVICE_NAMES.reverse.each do |service_name|
      log "Stopping #{service_name}"
      logged_system_call("service #{service_name} stop")
      logged_system_call("killall redis-server") if service_name == :"redis-server"
    end
    exit(Signal.list[signal.to_s])
  end
end

# ==== PREPARE CONTAINER AND START SERVICES ====
SERVICE_NAMES = [:ssh, :"redis-server", :cron, :nginx, :"passenger-exporter", :foreman].freeze

logged_system_call("bash /erb.templates/render.sh")
logged_system_call("bash /bootstrap.sh")
logged_system_call('chown -R webapp:webapp "/home/webapp" &')

SERVICE_NAMES.each do |service_name|
  logged_system_call("service #{service_name} start")
end

log "All services started. Waiting for interrupt..."

# ==== REAP ALL ZOMBIE AND DEFUNCT SERVICES ====
Process.waitall
exit(1)
