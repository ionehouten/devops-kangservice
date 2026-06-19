# Reusable Workflow

# Build Docker Image

This reusable workflow automates the process of checking out source code, generating image versions, authenticating to cloud registries (AWS, GCP, or GHCR), building a Docker image with dynamic build arguments, and uploading the build environment as an artifact.

---

## 📋 Inputs

| Input | Type | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `environment` | `string` | **Yes** | - | Target deployment environment (e.g., Development, Staging, Production). |
| `image_repo` | `string` | **Yes** | - | The target container registry repository path. |
| `image_suffix` | `string` | **Yes** | - | Suffix to append to the image name based on environment or branch. |
| `context` | `string` | No | `.` | Docker build context directory. |
| `dockerfile` | `string` | No | `Dockerfile` | Path to the Dockerfile relative to the context. |

---

## 🔐 Secrets Configuration

To allow this workflow to authenticate with your cloud provider or registry, you must declare the following secrets in your calling repository. 

> 💡 **Note:** All secrets are marked as `required: false` so you only need to configure the secrets relevant to your chosen provider (e.g., only set up GCP secrets if you are using GCP).

### GitHub Container Registry (GHCR)
* `GHCR_DOMAIN`: The target GHCR domain (e.g., `ghcr.io`).

### Amazon Web Services (AWS)
* `AWS_REGION`: The target AWS region (e.g., `ap-southeast-1`).
* `AWS_ROLE_ARN`: The AWS IAM Role Amazon Resource Name (ARN) to assume via OIDC.

### Google Cloud Platform (GCP)
* `GCP_PROJECT_ID_DEV`: GCP Project ID for Development environment.
* `GCP_SA_DEV`: Google Service Account email for Development.
* `GCP_PROJECT_ID_STG`: GCP Project ID for Staging environment.
* `GCP_SA_STG`: Google Service Account email for Staging.
* `GCP_PROJECT_ID_PRD`: GCP Project ID for Production environment.
* `GCP_SA_PRD`: Google Service Account email for Production.
* `GCP_PROJECT_ID_SHARED`: GCP Project ID for Shared container registries.
* `GCP_SA_SHARED`: Google Service Account email for Shared registry access.

---

## 🚀 Usage Example

Here is how you can call this reusable workflow from your pipeline. Make sure to include `secrets: inherit` so the workflow can safely access your repository credentials.

```yaml
name: CI Pipeline

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target Environment'
        required: true
        default: 'Development'
        type: choice
        options:
          - Development
          - Staging
          - Production

jobs:
  GlobalVariable:
    runs-on: ubuntu-latest
    outputs:
      environment: ${{ steps.prepare.outputs.environment }}
      image_tag: ${{ steps.prepare.outputs.image_tag }}
      image_suffix: ${{ steps.prepare.outputs.image_suffix }}
    steps:
      - name: Prepare Environment
        id: prepare
        uses: ionehouten/devops-kangservice/.github/actions/env-prepare-manual@main
        with:
          environment: ${{ inputs.environment }}
          provider: "GHCR"
          image_name: "custom-nginx"

  Build:
    needs: [GlobalVariable]
    uses: ibncorp/haus-devops/.github/workflows/build-docker.yaml@main
    with:
      environment: ${{ needs.GlobalVariable.outputs.environment }}
      image_repo: ${{ needs.GlobalVariable.outputs.image_tag }}
      image_suffix: ${{ needs.GlobalVariable.outputs.image_suffix }}
    secrets: inherit # Required to pass repository secrets into the reusable workflow
```

## 📦 Artifacts Generated
- build: A zip artifact containing a build.env file. 
  This file records the generated IMAGE_TAG and IMAGE_TAG_LATEST values used during the build process, which can be downloaded or consumed by down-stream deployment jobs.