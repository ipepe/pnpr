#!/bin/bash

# This script is used to render ERB templates
set -e

for f in /erb.templates/templates/*; do
  echo "Running script: $f"
  ruby "$f"
done