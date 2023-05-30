#!/usr/bin/env bash

GITLAB_API_URL=${2:-${GITLAB_API_URL:-"https://gitlab.com/api/v4"}}
GITLAB_TOKEN=${3:-${GITLAB_TOKEN}}
GITLAB_PROJECT_ID=${4:-${GITLAB_PROJECT_ID}}

INPUT=$(cat "$1")

RESPONSE=$(
  jq --null-input --arg yaml "$INPUT" '.content=$yaml' \
   | curl -s "${GITLAB_API_URL}/projects/${GITLAB_PROJECT_ID}/ci/lint" \
      --header 'Content-Type: application/json' \
      --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
      --data @-
)

echo "$RESPONSE"

STATUS=$(echo "$RESPONSE" | jq -r '.valid')

if [[ $STATUS == 'true' ]]; then
    exit 0
elif [[ $STATUS == 'false' ]]; then
    exit 1
else
    exit 2
fi