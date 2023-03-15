#!/usr/bin/env ruby

# this script has 3 purposes:
# 1. prepare container (file permissions, etc) and start all relevant services in proper order
# 2. when receiving interrupt, forward this interrupt to all child processes
# 3. reap all zombie/defunct processes

# ==== PREPARE CONTAINER AND START SERVICES ====
system("source /etc/environment")
# start these services in the background: redis-server, ssh, nginx, cron
system("service ssh start")
# system("service redis-server start")
system("service nginx start")
# system("service cron start")

# ==== RECEIVE AND FORWARD INTERRUPT SIGNALS TO CHILD PROCESSES ====
["INT", "TERM"].each do |signal|
  Signal.trap(signal) do
    puts "Received #{signal}"
    exit(2)
  end
end

# ==== REAP ALL ZOMBIE AND DEFUNCT SERVICES ====
loop do
  begin
    pid, status = Process.wait2
    warn "Process: #{pid}, exited with status #{status}"
  rescue Errno::ECHILD => e
    warn e.message
    exit(1)
  end
end
