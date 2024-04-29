# Kustomized Helm Action

This GitHub Action generates manifests for Helm charts and kustomize overlays.

## Inputs

### `source_folder`

The folder containing the Helm charts and kustomize overlays. This input is required. The default value is `dev`.

### `destination_branch`

The branch to commit the changes to. This input is not required. The default value is the current branch of the head commit.

### `helm_version`

The version of Helm to use. This input is not required. The default value is `v3.14.4`.

## Usage

```yaml
- uses: JamesD/Kustomized-Helm-Action@v1
  with:
    source_folder: 'your-folder'
    destination_branch: 'your-branch'
    helm_version: 'your-helm-version'
```

## Steps

1. Configures git user name and email to `github-actions[bot]` and `github-actions[bot]@users.noreply.github.com` respectively.

2. Sets up Helm using the `azure/setup-helm@v4.2.0` action with the version specified in the `helm_version` input.

3. Gets directories for processing. It finds directories that match the pattern `./<source_folder>/*/overlays/*` and stores them in the `dirs` environment variable.

4. Adds Helm repositories dynamically (details not provided in the excerpt).

## Author

James D.

## Branding

The action icon is `git-merge` and the color is `red`.

Please note that this is a composite run steps action.