#!/bin/bash

#
# Helper script to load custom extensions from extensions folder.
#
# This is not a native Lando feature. It is a workaround to load extensions because we
# only have one .lando.base.yml and we want to be able to keep it minimal and then
# add extensions on top of it, e.g., node, elasticsearch, etc.
#

cd /app

source vendor/wunderio/lando-drupal/scripts/_common.sh

# Check if no arguments were provided.
if [ "$#" -eq 0 ]; then
  log_message "Error: No extension name provided. Please provide an extension name to disable."
  exit 1
fi

setup_yq

# Helper to disable extension in .lando.yml.
#
# This function removes the specified extensions from the .lando.yml file
# under the wunderio:extensions configuration. The extensions are provided
# as a comma-separated string. If an extension is not present in .lando.yml,
# it logs a message indicating that the extension is not found.
#
# Parameters:
#   $1: extensions - A comma-separated string of extension names to be disabled.
disable_extension() {
  extensions="$1"  # Extensions are provided as a comma-separated string.
  IFS=',' read -ra extension_array <<< "$extensions"  # Split the string into an array.

  for extension in "${extension_array[@]}"; do
    # Check if the extension is in the .lando.yml file.
    extension_in_lando_yml=$(yq eval ".wunderio.extensions[] | select(. == \"${extension}\")" .lando.yml)

    if [ -n "$extension_in_lando_yml" ]; then
      # If the extension is found, remove it.
      yq eval ".wunderio.extensions -= [\"${extension}\"]" -i .lando.yml
      log_message "Removed \"${extension}\" extension from .lando.yml."
    else
      log_message "\"${extension}\" extension is not in .lando.yml; skipping."
    fi
  done
}

# Update .lando.yml and add the extension if it was passed as an argument.
if [ -n "$1" ]; then
  # Remove the extension to .lando.yml.
  extension_name="$1"
  disable_extension "$extension_name"
fi

install_enabled_extensions

# Print out help message to user to suggest rebuilding Lando now.
if [ -n "$1" ]; then
  echo
  echo "Run 'lando rebuild' to apply the changes."
fi
