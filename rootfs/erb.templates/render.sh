#!/bin/bash

# This script is used to render ERB templates
set -e

echo "Started render.sh at $(date)"

for f in /erb.templates/templates/*; do
  echo "Running script: $f"
  ruby "$f"
done