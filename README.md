# Kustomized Helm Action

This GitHub Action generates manifests for Helm charts and then combines them in kustomize overlays.

This action is insanely opinionated about how I run my repository. It may not support your use case, but please feel free to fork and modify it to suit your needs.

This action expects a folder structure of `./<source_folder>/<app_name>/overlays/<cluster_identifier>` where `<source_folder>` is the input provided to the action. 

*  `<source_folder>` can be thought of environment names like `dev`, `staging`, and `production`. Or as other clear seperations of concerns. The action will generate manifests for each environment and commit them to the destination branch.

* `<app_name>` is the name of the application. This is used by `argocd` to identify the application when used with an `applicationset`.

* `<cluster_identifier>` is the name of the cluster. This is used by `argocd` to identify the cluster when used with an `applicationset`.

```
dev
  myapp
    base
      Chart.yaml
      kustomization.yaml
      values.yaml
    overlays
      cluster1`
        kustomization.yaml
        my-patch.yaml
        values.yaml
      cluster2`
        kustomization.yaml
        values.yaml
staging
  myapp
    base
      Chart.yaml
      kustomization.yaml
      values.yaml
    overlays
      cluster1
        kustomization.yaml
        values.yaml
      cluster2
        kustomization.yaml
        values.yaml
```
## Inputs

### `source_folder`

The folder containing the Helm charts and kustomize overlays. This input is required. The default value is `dev`.

### `destination_branch`

The branch to commit the changes to. This input is not required. The default value is the current branch of the head commit.

### `helm_version`

The version of Helm to use. This input is not required. The default value is `v3.14.4`.

## Usage

```yaml
- uses: jamesatintegratnio/Kustomized-Helm-Action@main
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