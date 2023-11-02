# Node extension

This extension adds Node.js 16 and npm to the Lando configuration.

## Installation

1. Add to your local .lando.yml file:

   ```
   wunderio:
     extensions:
       - node
   ```

2. Rebuild Lando:

   ```
   # Need to run once after updating the extensions so you would not need to rebuild 2 times.
   # This will merge the extension configuration into .lando.base.yml.
   lando load-wunderio-lando-drupal-extensions
   # Rebuild Lando.
   lando rebuild
   ```

## Overview

**Configuration Overview:**

**Tooling Commands:**

- **npm:** Runs npm commands.

**Services:**

- **node:** Configuration for Node.js 16, with npm installation.
