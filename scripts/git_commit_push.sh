#!/bin/bash
set -eo pipefail

env
# Check if required variables are set
for var in DRY_RUN DESTINATION_BRANCH COMMIT_MESSAGE COMMIT_ID; do
  if [ -z "${!var}" ]; then
    echo "Error: $var is not set. Please set it before running the script."
    exit 1
  fi
done

if [ "$DRY_RUN" = "true" ]; then
  echo "Skipping commit step due to dry_run"
  echo "Generated all.yaml files: "
  find . -name "all.yaml" -type f -exec cat {} \;
  exit 0
fi

if ! git fetch origin "$DESTINATION_BRANCH":"$DESTINATION_BRANCH"; then
  echo "Failed to fetch changes from origin, will create the branch instead"
fi

git stash

if git show-ref --verify refs/heads/"$DESTINATION_BRANCH"; then
  git switch  "$DESTINATION_BRANCH"
else
  git switch --create  "$DESTINATION_BRANCH" origin/"$DESTINATION_BRANCH" || git switch --create "$DESTINATION_BRANCH"
fi

git rm -rf . --quiet
git stash pop
git add **/all.yaml

if ! git diff --quiet --staged; then
  git commit -uno -m "${COMMIT_MESSAGE} (Built from ${COMMIT_ID})"
  if git push --set-upstream origin "$DESTINATION_BRANCH"; then
    echo "Push successful"
  else
    echo "Push failed"
    exit 1
  fi
  echo "Changes committed and pushed to branch"
else
  echo "No changes detected"
fi