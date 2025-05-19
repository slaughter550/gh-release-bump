#!/bin/zsh

# Fetch the latest tag sorted by semantic versioning
latest_tag=$(git tag --sort=-v:refname | head -n 1)

# If no tag exists, assume an initial version of v0.0.0
if [[ -z "$latest_tag" ]]; then
  echo "No tags found. Starting from v0.0.0"
  latest_tag="v0.0.0"
fi

# Remove a leading 'v' if present and split into components
version=${latest_tag#v}
IFS='.' read -r major minor patch <<< "$version"

echo "Latest release version: v${major}.${minor}.${patch}"

# Prompt the user for the type of version bump
echo "Which version bump would you like to perform? (patch/minor/major)"
read bump

case $bump in
  patch)
    patch=$((patch + 1))
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  *)
    echo "Invalid input. Please enter 'patch', 'minor', or 'major'."
    exit 1
    ;;
esac

new_version="v${major}.${minor}.${patch}"
echo "New version will be: $new_version"

# Create a GitHub release using the GitHub CLI.
# This command will create a new tag (if it doesn't exist) from the current branch head,
# generate release notes automatically, and publish the release.
gh release create "$new_version" --generate-notes --target $(git rev-parse HEAD)

if [ $? -eq 0 ]; then
  echo "GitHub release $new_version created successfully."
else
  echo "Failed to create GitHub release."
  exit 1
fi
