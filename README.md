# Wunder template for Lando Drupal projects

This is a template for Lando Drupal projects for defining the base Lando setup for Drupal.
It creates .lando.base.yml file and .lando/core/ folder. You still need .lando.yml to define
minimally the *name* parameter.

## Installation

1. Add this to your `composer.json`:
   ```json
   {
       "extra": {
           "dropin-paths": {
               "/": [
                   "package:wunderio/lando-drupal"
               ]
           }
       }
   }
   ```

2. Then install the composer package as usual with:

   ```
   composer require wunderio/lando-drupal --dev
   ```

3. Add these into the main project's `.gitignore`:
   ```
   # wunderio/lando-drupal
   .lando.base.yml
   .lando/core/
   ```

4. Add changes to GIT:
   ```
   git add .lando/custom/ &&
   git add -p .gitignore composer.json composer.lock
   ```

5. Depending on your project either create or update your .lando.yml.

   If you are creating new project, then you need to create .lando.yml file with the following:
   ```
   name: your-project-name

   # Optional to make sure upstream does not change this eg to drupal11 at some point.
   recipe: drupal10
   ```

   In case you already had .lando.yml then remove anything that already exists in
   .lando.base.yml. If you have any custom code in .lando/ then move these to
   .lando/custom/ folder and change the references in .lando.yml

6. Optionally enable disabled services in .lando.base.yml by copying these over to .lando.yml and
   uncomment them.


## Overview

**Configuration Overview:**

- **Name:** drupal-project
- **Recipe:** drupal10

**PHP and Web Server:**

- **PHP Version:** 8.1
- **Web Server:** Nginx
- **Webroot:** web

**Database:**

- **Database Version:** MariaDB 10.3

**Composer:**

- **Composer Version:** 2

**Xdebug:**

- **Xdebug Mode:** Off (enabled by `lando xdebug` command)

**Custom Configuration Files:**

- Custom PHP configuration file: .lando/core/php.ini
- Custom database configuration file: .lando/core/my.cnf

**Tooling Commands:**

- **composer:** Runs Composer commands.
- **grumphp:** Runs GrumPHP commands.
- **npm:** Runs npm commands.
- **phpunit:** Runs PHPUnit commands with custom options.
- **regenerate-phpunit-config:** Regenerates fresh PHPUnit configuration.
- **varnishadm:** Runs varnishadm commands.
- **xdebug:** Loads Xdebug in the selected mode.

**Services:**

- **appserver:** Configuration for the primary application server.
- - Sets the timezone to "Europe/Helsinki."
- - Defines environment variables including HASH_SALT, ENVIRONMENT_NAME, DB_NAME_DRUPAL, DB_USER_DRUPAL, DB_PASS_DRUPAL, DB_HOST_DRUPAL, DRUSH_OPTIONS_URI, VARNISH_ADMIN_HOST, XDEBUG_MODE, and PHP_IDE_CONFIG.
- - Provides PHPUnit settings for headless Chrome.
- **chrome:** Configuration for running Chrome WebDriver.
- **mailhog:** Configuration for MailHog, a mail testing tool.
- **node:** Configuration for Node.js 16, with npm installation.
- **proxy:** Configuration for proxy settings.

**Custom Events:**

- **post-db-import:** Custom event to rebuild Drupal cache and log in the local user after a database import.

**Environment File:**

- Uses an environment file located at .lando/contrib/.env.

**Lando Version:**

- Tested with Lando version v3.18.0.

**Notes:**

- This Lando configuration is designed for a Drupal 10 project.
- It includes custom PHP and database configuration files.
- Tooling commands are provided for Composer, GrumPHP, npm, PHPUnit, Varnishadm, and Xdebug.
- Services are configured for the primary application server, Chrome WebDriver, MailHog, and Node.js.
- Custom events are defined to perform actions after a database import.
- The configuration is tested with Lando version 3.18.0.
- Please make sure to adjust any paths or configurations as needed for your specific project and environment.
