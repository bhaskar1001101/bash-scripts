#!/bin/bash

# Config
GITHUB_TOKEN=""
EMAIL="bhaskarmetiya@gmail.com"
REPO="llvm/llvm-project"  
LOG_FILE="/home/bhaskar/scripts/github_issues.log"

init_log() {
    touch "$LOG_FILE"
}

fetch_issues() {
    local response
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO/issues?labels=good+first+issue&state=open&per_page=100")
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch issues from GitHub" >&2
        exit 1
    fi
    
    echo "$response"
}

process_issues() {
    local response="$1"
    local temp_file=$(mktemp)
    
    while IFS='|' read -r url title; do
        if ! grep -q "$url" "$LOG_FILE"; then
            echo "$url | $title" >> "$LOG_FILE"
            echo -e "Title: $title\nURL: $url\n" >> "$temp_file"
        fi
    done < <(echo "$response" | jq -r '.[] | .html_url + "|" + .title')
    
    echo "$temp_file"
}

# https://myaccount.google.com/apppasswords
# https://superuser.com/questions/351841/how-do-i-set-up-the-unix-mail-command
send_notification() {
    local temp_file="$1"
    
    if [ -s "$temp_file" ]; then
        mail -s "New Good First Issues in ${REPO}" "$EMAIL" << EOF
New good first issues in ${REPO}:

$(cat "$temp_file")
EOF
    fi
}

# Cleanup old entries in log file
# cleanup_log() {
#     if [ $(wc -l < "$LOG_FILE") -gt 100 ]; then
#         tail -n 100 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
#     fi
# }

main() {
    init_log
    
    local response
    response=$(fetch_issues)
    
    local temp_file
    temp_file=$(process_issues "$response")
    
    send_notification "$temp_file"
    rm "$temp_file"
}

main