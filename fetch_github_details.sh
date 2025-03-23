#!/bin/bash

# Function to fetch details from GitHub issue or pull request
fetch_github_details() {
    local url_or_issue="$1"
    local repo="${GITHUB_REPOSITORY}"  # Automatically use the current repository
    local token="$GITHUB_TOKEN"  # Ensure this environment variable is set

    # Determine if the input is a full URL or an issue number
    if [[ "$url_or_issue" =~ ^https://github\.com/ ]]; then
        api_url="${url_or_issue/github.com/api.github.com/repos}"
        # Extract the repo from URL if provided
        repo_from_url=$(echo "$url_or_issue" | sed -E 's|https://github.com/([^/]+/[^/]+).*|\1|')
        # If the URL contains issue or PR number, use it directly
        if [[ "$url_or_issue" =~ issues/[0-9]+ || "$url_or_issue" =~ pull/[0-9]+ ]]; then
            api_url="${url_or_issue/github.com/api.github.com/repos}"
        else
            # Otherwise construct the API URL using the repo from URL
            api_url="https://api.github.com/repos/${repo_from_url}"
        fi
    else
        # If just an issue number is provided (e.g., #123), use the current repository
        api_url="https://api.github.com/repos/$repo/issues/${url_or_issue/#\#/}"
    fi

    echo "Fetching details from: $api_url" >&2

    # Fetch details using GitHub API
    response=$(curl -s -H "Authorization: token $token" "$api_url")

    # Check for errors
    if [[ $(echo "$response" | jq -r '.message // empty') == "Not Found" ]]; then
        echo "{\"type\": \"unknown\", \"label\": \"\"}" >&2
        return
    fi

    # Extract type and label from the response
    type="unknown"
    if [[ $(echo "$response" | jq -r '.pull_request // empty') != "" ]]; then
        type="pull_request"
    elif [[ $(echo "$response" | jq -r '.url // empty') == *"/issues/"* ]]; then
        type="issue"
    fi

    # Look for specific labels or types
    labels=$(echo "$response" | jq -r '.labels[]?.name' 2>/dev/null || echo "")
    label=""
    
    if [[ "$labels" == *"bug"* ]]; then
        label="bug"
    elif [[ "$labels" == *"feature"* ]]; then
        label="feature"
    fi

    # Return type and label as a JSON object
    echo "{\"type\": \"$type\", \"label\": \"$label\"}"
}

# Example usage
# details=$(fetch_github_details "#123")
# echo "$details" 