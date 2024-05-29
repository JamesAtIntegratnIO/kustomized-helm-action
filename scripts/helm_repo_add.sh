#!/bin/bash
set -eo pipefail

declare -A repos

# Loop over directories to build the list of repositories
IFS=',' read -r -a dir_array <<<"${DIRS}"
for dir in "${dir_array[@]}"; do
  if [ -d "$dir" ]; then
    echo "Processing directory: $dir"
    cd $dir
    cd ../../base
    if [ -f Chart.yaml ]; then
      echo "Chart.yaml found in the base directory"
      dependencies=$(yq e '.dependencies[] | (.name + "=" + .repository)' Chart.yaml)
      IFS=$'\n'
      for dep in $dependencies; do
        repo_name="${dep%=*}"
        repo_url="${dep#*=}"
        if [ ! -z "$repo_url" ]; then
          # Add the repository to the associative array
          repos["$repo_name"]="$repo_url"
        fi
      done
    else
      echo "Chart.yaml does not exist in the base directory"
    fi
    cd $GITHUB_WORKSPACE
  fi
done

# Add and update the repositories
if [ ${#repos[@]} -gt 0 ]; then
  for repo_name in "${!repos[@]}"; do
    repo_url="${repos[$repo_name]}"
    echo "Adding Helm repository: $repo_name=$repo_url"
    helm repo add "$repo_name" "$repo_url"
  done
  echo "Updating Helm repositories"
  helm repo update
else
  echo "No repositories found. Skipping repository update."
fi
