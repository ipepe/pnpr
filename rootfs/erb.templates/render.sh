#!/bin/bash

# This script is used to render ERB templates

for f in /erb.templates/*; do
  echo "Running script: $f"
  ruby "$f" || echo "Script failed: $f"
done