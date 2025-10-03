#!/usr/bin/env bash
set -euo pipefail

source .env

find . -type f  -name  "*.sh" -o -name  "*.yaml" -o -name "*.yml" | while read -r file; do
  for var in $(compgen -v | grep ^var_)
    do   
      val=${!var:-}
      #echo "  Remplacement de $var par $val dans $file"
      sed -i "s@'.*' #${var}@'${val}' #${var}@" "$file"
    done
done
