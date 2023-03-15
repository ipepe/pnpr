# /docker-entrypoint.rb

I decided to write my own PID1 script to manage processes and services in docker container.

A great resource that was super helpful on managing processes and signals was <https://workingwithruby.com/wwup/wait/> and <https://workingwithruby.com/wwup/signals/>.

This script has 3 main purposes to fulfill:
1. prepare container (file permissions, etc) and start all relevant services in proper order 
2. when receiving interrupt, forward this as "service stop" to all relevant services 
3. reap all zombie/defunct processes
