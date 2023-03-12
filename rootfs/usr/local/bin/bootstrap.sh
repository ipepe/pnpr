#!/usr/bin/env bash

echo "Started boostrap.sh at $(date)"
echo "Load environment variables from /etc/environment"
source /etc/environment

echo "Making sure that the user has the correct permissions"
chmod g+x,o+x /home/webapp/webapp

echo "Running all /root/on_startup.d scripts"
for f in /root/on_startup.d/*; do
  echo "Running script: $f"
  bash "$f" || echo "Script failed: $f"
done


echo "Running all /home/webapp/on_startup.d scripts"
for f in /home/webapp/on_startup.d/*; do
  echo "Running script: $f"
  chown webapp:webapp "$f"
  gosu webapp bash "$f" || echo "Script failed: $f"
done

echo "Finished bootstrap.sh at $(date)"
