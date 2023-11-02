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
   lando rebuild
   ```

## Overview

**Configuration Overview:**

**Tooling Commands:**

- **npm:** Runs npm commands.

**Services:**

- **node:** Configuration for Node.js 16, with npm installation.
