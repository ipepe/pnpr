#!/usr/bin/env bash

echo "Started root_boot.sh at $(date)"
echo "Load environment variables from /etc/environment"
source /etc/environment

echo "Making sure that the user has the correct permissions"
chmod g+x,o+x /home/webapp/webapp
chown -R webapp:webapp "/home/webapp" &

echo "Running all on_startup.d scripts"
for f in /home/webapp/on_startup.d/*; do
  echo "Running script: $f"
  chown -R webapp:webapp "$f"
  gosu webapp bash  "$f" || echo "Script failed: $f"
done

echo "Finished root_boot.sh at $(date)"
exit 1