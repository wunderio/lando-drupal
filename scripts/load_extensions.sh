#!/bin/bash

# Use yq to extract the extensions section
cd ..

echo $(pwd)

extensions=$(docker run --rm -v "$(pwd)":/workdir mikefarah/yq eval '.wunderio.extensions[]' .lando.yml)

# Iterate over the extensions
for extension in $extensions; do
    echo "Extension: $extension"
    # Add your processing logic here
done
