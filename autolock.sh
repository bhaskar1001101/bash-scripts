#!/usr/bin/env bash

# Run xidlehook
xidlehook \
  `# Don't lock when there's audio playing` \
  --not-when-audio \
  `# Dim the screen after 60 seconds, undim if user becomes active` \
  --timer 60 \
    'xrandr --output "eDP" --brightness .7' \
    'xrandr --output "eDP" --brightness 1' \
  `# Undim & lock after 10 more seconds` \
  --timer 10 \
    'xrandr --output "eDP" --brightness 1; i3lock -c "000000"' \
    '' \
  `# Finally, suspend an hour after it locks` \
  --timer 10 \
    'loginctl suspend' \
    ''
