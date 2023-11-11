#
# _common.sh
#
# This file contains common functions used by other scripts.
#

# Helper to print log messages to the user.
#
# Parameters:
#   $1: message - The message to be logged.
log_message() {
  echo "wunderio/lando-drupal: $1"
}

# Install yq tool to be able to merge YAML files.
#
# In Lando installation is done in ~/bin directory as we don't have root access.
# So in Lando, we use the freshly installed ~/bin/yq, otherwise in host,
# we use the Docker container.
setup_yq() {
  # Define the desired version of yq.
  YQ_VERSION="4.35.2"

  if [ -n "$LANDO" ]; then
    # Check if the `yq` binary already exists.
    if [ -f ~/bin/yq ]; then
      yq() {
        ~/bin/yq "$@"
      }

      return
    fi

    # Define the architecture-specific URL.
    YQ_URL="https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64"

    # Check if the ~/bin directory exists, and if not, create it.
    [ -d ~/bin ] || mkdir -p ~/bin

    # Download yq binary.
    wget -q "$YQ_URL" -O ~/bin/yq
    chmod +x ~/bin/yq

    # Add ~/bin to PATH if not already there.
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
      echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
      # Add it to the current shell session as well.
      export PATH="$HOME/bin:$PATH"
    fi

    yq() {
      ~/bin/yq "$@"
    }

    # Inform the user that installation is complete.
    log_message "yq has been installed."
  else
    # Function to run yq using the Docker container in the host.
    yq() {
      docker run --rm -v "$(pwd)":/workdir mikefarah/yq:$YQ_VERSION "$@"
    }
  fi
}

# Install enabled extensions
#
# This function reads the list of enabled extensions from .lando.yml,
# iterates through them, and merges their respective .lando.yml
# configuration files into the main .lando.base.yml, effectively
# installing and enabling these extensions for the project.
# Each extension is expected to have its configuration in the
# 'vendor/wunderio/lando-drupal/extensions' directory.
#
# This function uses the yq tool to perform YAML manipulation and
# logs the installation process using log_message.
install_enabled_extensions() {
  # Use yq to extract the extension values from .lando.yml and store them in an array.
  extensions=($(yq eval '.wunderio.extensions[]' .lando.yml))

  # Always fetch the clean .lando.base.yml from Github before doing
  # any changes to it. We might not even have vendor folder available
  # to reset it from there. If we always start from fresh and re-add
  # extensions, then we've also implemented removal of extensions at
  # the same time.
  LANDO_DRUPAL_PACKAGE_VERSION=$(composer show | grep -oP 'wunderio/lando-drupal\s+\K\S+')

  # Check if the version is a valid version number
  if [[ "$LANDO_DRUPAL_PACKAGE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    BASE_YML_URL="https://raw.githubusercontent.com/wunderio/lando-drupal/${LANDO_DRUPAL_PACKAGE_VERSION}/.lando.base.yml"
    wget -q -O .lando.base.yml "$BASE_YML_URL"
  else
    log_message "Invalid version: $LANDO_DRUPAL_PACKAGE_VERSION. Skipping download of .lando.base.yml."
  fi

  # Check if the extensions array is empty.
  if [ ${#extensions[@]} -eq 0 ]; then
    log_message "No more extensions are enabled. Run 'lando rebuild' if you removed any extension."
    exit 0
  fi

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
      log_message "$extension_dir extension does not exist."
    fi
  done
}
