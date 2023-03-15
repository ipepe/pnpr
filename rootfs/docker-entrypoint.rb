#!/usr/bin/env ruby

system("source /etc/environment")
# start these services in the background: redis-server, ssh, nginx, cron
system("service ssh start")
system("service redis-server start")
system("service nginx start")
system("service cron start")

sleep

txt = <<~RUBY
  # Define the PID 1 process to run
  pid_1_cmd = "/usr/bin/my_custom_process"

  # Start the PID 1 process
  pid_1_pid = Process.spawn(pid_1_cmd)

  # Set up the signal handlers
  ["INT", "TERM"].each do |signal|
    Signal.trap(signal) do
      Process.kill(signal, pid_1_pid) if pid_1_pid
      exit
    end
  end



  # Wait for the PID 1 process to exit
  Process.wait(pid_1_pid)

  # Exit with the PID 1 process exit code
  exit $CHILD_STATUS.exitstatus

  system("service ssh start")

  # Then, start nginx
  system("nginx")

  # Perform a rudimentary health check by attempting to connect to nginx
  require "net/http"
  require "uri"

  uri = URI.parse("http://localhost")
  response = Net::HTTP.get_response(uri)

  if response.code == "200"
    puts "nginx is up and running!"
  else
    puts "nginx is not running!"
  end

  # Sleep indefinitely to keep the container alive
  sleep
RUBY
