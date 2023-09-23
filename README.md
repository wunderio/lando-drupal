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
   # wunderio/lando-drupal:
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
