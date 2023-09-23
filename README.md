# Wunder template for Lando Drupal projects

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
composer wunderio/lando-drupal:^1
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
