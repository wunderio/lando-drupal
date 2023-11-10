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

install_yq

# Helper to write extension to .lando.yml.
add_extension() {
  extensions="$1"  # Extensions are provided as a comma-separated string.
  IFS=',' read -ra extension_array <<< "$extensions"  # Split the string into an array.

  for extension in "${extension_array[@]}"; do
    # Build the path to the extension-specific .lando.yml file
    extension_dir="vendor/wunderio/lando-drupal/extensions/${extension}"
    extension_path="${extension_dir}/.lando.yml"

    if [ ! -f "$extension_path" ]; then
      log_message "Won't write to .lando.yml as extension \"${extension}\" does not exist at ${extension_dir}."
      continue
    fi

    # Check if the extension is already in the .lando.yml file.
    extension_in_lando_yml=$(yq eval ".wunderio.extensions[] | select(. == \"${extension}\")" .lando.yml)
    if [ -n "$extension_in_lando_yml" ]; then
      log_message "\"${extension}\" extension is already in .lando.yml; skipping."
    else
      # If the extension is not found, add it.
      yq eval ".wunderio.extensions += [\"${extension}\"]" -i .lando.yml
      log_message "Added \"${extension}\" extension to .lando.yml under wunderio:extensions."
    fi
  done
}

# Update .lando.yml and add the extension if it was passed as an argument.
if [ -n "$1" ]; then
  # Add the extension to .lando.yml.
  extension_name="$1"
  add_extension "$extension_name"
fi

# Use yq to extract the extension values from .lando.yml and store them in an array.
extensions=($(yq eval '.wunderio.extensions[]' .lando.yml))

# Iterate over the array of extensions and merge them to project.
for extension in "${extensions[@]}"; do
  log_message "Preparing to install extension: $extension"
  # Build the path to the extension-specific .lando.yml file
  extension_dir="vendor/wunderio/lando-drupal/extensions/$extension"
  extension_path="$extension_dir/.lando.yml"

  # Check if the extension_path exists before merging.
  if [ -f "$extension_path" ]; then
    # Use yq to merge the extension-specific .lando.yml into .lando.base.yml
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' .lando.base.yml "$extension_path" > .lando.base.tmp.yml
    mv .lando.base.tmp.yml .lando.base.yml
    log_message "Successfully installed $extension extension."
  else
    echo "$extension_dir extension does not exist."
  fi
done

# Print out help message to user to suggest rebuilding Lando now.
if [ -n "$1" ]; then
  echo
  echo "Run 'lando rebuild' to apply the changes."
fi
