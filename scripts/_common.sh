#
# _common.sh
#
# This file contains common functions used by other scripts.
#

# Help to print messages to the user.
log_message() {
  echo "wunderio/lando-drupal: $1"
}

# Install yq tool to be able to merge YAML files.
# Installation is done in ~/bin directory as we don't have root access.
install_yq_inside_lando() {
  # Define the desired version of yq.
  YQ_VERSION="4.35.2"

  # Check if the `yq` binary already exists.
  if [ -f ~/bin/yq ]; then
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

  # Inform the user that installation is complete.
  log_message "yq has been installed."
}

# Make sure yq is available and assign it to yq wrapper we can use in this script.
# If we are inside Lando, we use the freshly installed ~/bin/yq, otherwise in host,
# we use the Docker container.
install_yq() {
  if [ -n "$LANDO" ]; then
    install_yq_inside_lando

    yq() {
      ~/bin/yq "$@"
    }
  else
    # Function to run yq using the Docker container in the host.
    yq() {
      docker run --rm -v "$(pwd)":/workdir mikefarah/yq "$@"
    }
  fi
}
