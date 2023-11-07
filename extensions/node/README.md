# Node extension

This extension adds Node.js 16 and npm to the Lando configuration.

## Installation

1. Add node extension to your .lando.yml file:

   ```
   lando load-wunderio-lando-drupal-extensions node
   ```

   This will write the following to your .lando.yml file:

   ```
   wunderio:
     extensions:
       - node
   ```

   You might want to adjust the position of the new entry in .lando.yml file. For example, if you have
   **version** parameters last, then you might want to move the wunderio entry before that. It's just
   a matter of preference.

2. Rebuild Lando:

   ```
   lando rebuild
   ```

3. Add the changes to GIT.

   ```
   git add .lando.base.yml .lando.yml
   ```

## Overview

**Configuration Overview:**

**Tooling Commands:**

- **npm:** Runs npm commands.

**Services:**

- **node:** Configuration for Node.js 16, with npm installation.
