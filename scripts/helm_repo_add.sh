# This script is used to initialize an associative array to hold repositories and add/update Helm repositories.
# It loops over directories specified in the 'dirs' variable and checks if a 'Chart.yaml' file exists in the base directory.
# If the file exists, it extracts the dependencies and their repository URLs using 'yq' command.
# It then adds the repositories to the associative array.
# Finally, it adds and updates the Helm repositories using the 'helm' command.

# Variables:
# - dirs: A comma-separated list of directories to process.

# Steps:
# 1. Initialize an associative array to hold the repositories.
# 2. Loop over the directories specified in 'dirs' variable.
#    a. Check if the directory exists.
#    b. If it exists, change the directory to the base directory.
#    c. Check if 'Chart.yaml' file exists in the base directory.
#       - If it exists, extract the dependencies and their repository URLs.
#       - Add the repositories to the associative array.
#    d. Change the directory back to the original directory.
# 3. Add and update the Helm repositories using the associative array.

# Initialize an associative array to hold the repositories
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
