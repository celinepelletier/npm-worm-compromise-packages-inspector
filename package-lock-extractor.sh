#!/bin/bash

ORG="$1"

if [ -z "$ORG" ]; then
  echo "Usage: $0 <org-name>"
  exit 1
fi

TMP_LOCK="tmp_package_lock.json"

echo "📦 Scanning all repositories in '$ORG' for package-lock.json files..."

repos=$(gh repo list "$ORG" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner')

for repo in $repos; do
  # Obtenir la branche par défaut
  default_branch=$(gh api "repos/$repo" --jq '.default_branch')

  # Récupérer l’arborescence complète
  tree=$(gh api "repos/$repo/git/trees/$default_branch?recursive=1")

  # Extraire tous les chemins des package-lock.json
  paths=$(echo "$tree" | jq -r '.tree[] | select(.path | endswith("package-lock.json")) | .path')

  if [ -z "$paths" ]; then
    continue
  fi

  for path in $paths; do
    echo "$repo Found: $path"

    # Télécharger le fichier brut
    download_url=$(gh api "repos/$repo/contents/$path?ref=$default_branch" --jq '.download_url')
    
    if [ -n "$download_url" ]; then
      curl -s -L "$download_url" -o "$TMP_LOCK"
      echo "📄 Parsing dependencies in $repo/$path..."
      node parse-lock.js "$repo/$path" "$TMP_LOCK"
      echo "----------------------------------"
      rm -f "$TMP_LOCK"
    else
      echo "⚠️  Could not get download URL for $repo/$path"
    fi
  done
done
