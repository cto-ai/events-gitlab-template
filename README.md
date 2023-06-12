# CTO.ai GitLab CI/CD Template

This GitLab template allows you to extend the Insights data received by CTO.ai. You can add data to you workflows for deployment tools that are not configured with GitLab's deployment API.

## Required Inputs

### `TOKEN`

The `TOKEN` variable should be your CTO.ai API token. You can follow [our docs to generate](https://cto.ai/docs/integrate-any-tool) your API token.

### `TEAM_ID`

Instructions for finding the CTO.ai Team ID which owns the received data can also be found [in our docs](https://cto.ai/docs/integrate-any-tool).

### `EVENT_NAME`

The name which represents the event being sent, e.g. "deployment".

### `EVENT_ACTION`

The state resulting from the event taking action, e.g. "failure" or "success".

## Optional Inputs

The following variables are optional inputs to your GitLab template, which may be required by more complex builds.

### `BRANCH`

The `BRANCH` field refers to the git branch name where the change occurs. When absent, the template will use the built-in environment variable `CI_COMMIT_BRANCH`, exposed by Gitlab CI/CD.

### `COMMIT`

The `COMMIT` field refers to the commit hash representing the current change. When absent, the template will use the built-in environment variable `CI_COMMIT_SHA`, exposed by Gitlab CI/CD.

### `REPO`

The `REPO` field refers to the repository name where the change is occurring. When absent, the template will use the built-in environment variable `CI_PROJECT_PATH`, exposed by Gitlab CI/CD.

### `ENVIRONMENT`

The `ENVIRONMENT` field refers to the environment in which the workflow is running. When absent, the template will use the built-in environment variable `CI_ENVIRONMENT_NAME`, exposed by Gitlab CI/CD.

### `IMAGE`

The `IMAGE` field refers to the OCI image name or ID associated with this event.

## Recommendations

Define 2 new secrets for your `TOKEN` and `TOKEN` to be passed into the template.

1. From your GitLab repo, click Settings -> CI/CD -> Variables
2. Create `CTOAI_TEAM_ID` variable using your CTO.ai-issued Team ID. Mask and protect the variable.
3. Create `CTOAI_EVENTS_API_TOKEN` variable using your CTO.ai-issued API Token. Mask and protect the variable.

## Example Usage

If you have a GitLab pipeline that deploys your application (e.g. serverless, npm publish, Azure, etc), you can drop this job in right after that step to capture the success or failure of that deployment. You can use [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) to control when to trigger `success` or `failure`.

We recommend adding `environment` to help differentiate multiple deployment events from the same repository to different environments or workflows. This will be reflected on your Insights Dashboard.

```yaml

include:
  - remote: 'https://raw.githubusercontent.com/cto-ai/events-gitlab-template/v0.0.1/cto.gitlab-ci.yml'

deploy_success:
  stage: cto_event
  variables:
    TEAM_ID: "${CTOAI_TEAM_ID}"
    TOKEN: "${CTOAI_EVENTS_API_TOKEN}"
    EVENT_NAME: "deployment"
    EVENT_ACTION: "success"
  when: on_success # Trigger if all jobs in pipeline were successful
  environment:
    name: production
  extends:
    - .cto-notify-event

deploy_failure:
  stage: cto_event
  variables:
    TEAM_ID: "${CTOAI_TEAM_ID}"
    TOKEN: "${CTOAI_EVENTS_API_TOKEN}"
    EVENT_NAME: "deployment"
    EVENT_ACTION: "failure"
  when: on_failure # Trigger if any of jobs in pipeline failed. job with `allow_failure` will not be considered failed job even in failure.
  environment:
    name: production
  extends:
    - .cto-notify-event

stages:
  # Previous Jobs
  - cto_event
```
