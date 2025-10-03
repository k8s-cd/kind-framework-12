#!/usr/bin/env bash
set -euo pipefail

source .env

# Parcourir tous les fichiers (pas seulement YAML) dans le dossier courant et les sous-dossiers
find . -type f | while read -r file; do
  echo "🔄 Traitement de $file"
  
  # Détecter toutes les variables qui commencent par var_git_
  for var in $(grep -o '#var_[a-zA-Z0-9_]\+' "$file" 2>/dev/null | sed 's/#//g' | sort -u); do
    val="${!var:-}"
    if [[ -n "$val" ]]; then
      echo "  Remplacement de $var par $val"
      sed -i "s|.*#${var}|repoURL: '${val}'#${var}|" "$file"
    else
      echo "  ⚠️  Variable $var non définie dans .env"
    fi
  done
done
