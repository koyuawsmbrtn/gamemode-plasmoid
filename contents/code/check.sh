#!/bin/bash

# Debug: show what we're checking
STATUS=$(gamemoded -s)
echo "Debug: gamemoded -s returned: $STATUS" >&2

if echo "$STATUS" | grep -q 'gamemode is active'; then
    echo "active"
else
    echo "inactive"
fi
