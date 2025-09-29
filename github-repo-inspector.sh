#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <github-user-or-org>"
  exit 1
fi

ORG_NAME="$1"
BRANCH_NAME="shai-hulud"
WORKFLOW_NAME="shai-hulud-workflow.yml"
WORKFLOW_PATH=".github/workflows/$WORKFLOW_NAME"

total=0
without_branch=0
workflow_not_found=0

repos=$(gh repo list "$ORG_NAME" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner')

while IFS= read -r repo; do
  total=$((total + 1))

  if gh api "repos/$repo/branches" | jq -e ".[] | select(.name == \"$BRANCH_NAME\")" > /dev/null; then
    echo "$repo has branch: $BRANCH_NAME"
  else
    without_branch=$((without_branch + 1))
  fi

  if gh api -X GET "repos/$repo/contents/$WORKFLOW_PATH" --silent > /dev/null 2>&1; then
    echo "$repo has workflow: $WORKFLOW_NAME"
  else
    workflow_not_found=$((workflow_not_found + 1))
  fi
done <<< "$repos"

echo "--------------------------------"
echo "Scanned $total repositories."

if gh repo view "$ORG_NAME/$BRANCH_NAME" --json name --silent > /dev/null 2>&1; then
  echo "❌ Repository '$ORG_NAME/$BRANCH_NAMEE' exists."
else
  echo "✅ Repository '$ORG_NAME/$BRANCH_NAME' does NOT exist."
fi

echo "✅ $without_branch repositories do NOT have the '$BRANCH_NAME' branch."
echo "❌ $((total - without_branch)) repositories HAVE the '$BRANCH_NAME' branch."

echo "✅ $workflow_not_found repositories do NOT have '$WORKFLOW_NAME'."
echo "❌ $((total - workflow_not_found)) repositories HAVE '$WORKFLOW_NAME'."
