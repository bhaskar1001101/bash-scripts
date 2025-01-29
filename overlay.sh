#!/bin/bash

# Install required tools (if you haven't already)
# sudo emerge xwinwrap imagemagick

# Path to the paper texture image
TEXTURE_PATH="$HOME/.config/i3/paper-texture.png"

# Create the texture image if it doesn't exist
if [ ! -f "$TEXTURE_PATH" ]; then
    echo "Creating default paper texture..."
    magick -size 1920x1080 canvas:white -noise 10 -colorspace Gray "$TEXTURE_PATH"
fi

# Start xwinwrap with the texture overlay, ensuring i3 ignores it
xwinwrap -g 1920x1080+0+0 -ni -b -nf -ov -- mpv --wid WID "$TEXTURE_PATH" --loop --no-audio --no-osc --no-input-default-bindings --idle --force-window=immediate

