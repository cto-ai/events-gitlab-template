# CTO.ai Gitlab CI/CD Template

This Gitlab template allows you to extend the insights data received by CTO.ai. You can add data to you workflows for deployment tools that are not configured with Gitlab's deployment API.

## Required Inputs

### `TOKEN`
CTO.ai api token, follow [these docs to generate](https://cto.ai/docs/integrate-any-tool)

### `TEAM_ID`
CTO.ai team ID sending the data, follow [these docs to access](https://cto.ai/docs/integrate-any-tool)

### `EVENT_NAME`

Name of event being sent i.e. "deployment"

### `EVENT_ACTION`

Action associated with event i.e. "failure", "progressing", "blocked" or "success"

## Recommendations

Define 2 new secrets for your `TOKEN` and `TOKEN` to be passed into the action.

1. From your GitHub repo, click Settings -> CI/CD -> Variables
2. Create `CTOAI_TEAM_ID` variable using your CTO.ai-issued Team Id. Mask and protect the variable.
3. Create `CTOAI_EVENTS_API_TOKEN` variable using your CTO.ai-issued API Token. Mask and protect the variable.

## Example Usage

If you have a Gitlab pipeline that deploys your application (i.e. serverless, npm publish, Azure, etc), you can drop this job in right after that step to capture the success or fail of that deployment. You can use [rules](https://docs.gitlab.com/ee/ci/yaml/#rules) to control when to execute `success` or `failure`

We recommend adding `environment` to help us help you differentiate multiple deployment events from the same repository to different environments or workflows. This will be reflected on your Insights Dashboard.

```yaml

include:
  - remote: 'https://raw.githubusercontent.com/cto-ai/gitlab-template/v1.0/cto.gitlab-ci.yml'


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
