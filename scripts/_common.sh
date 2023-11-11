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
