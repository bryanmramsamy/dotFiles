#!/bin/sh

CAMERA_GLYPH=""
MUTED_MIC_GLYPH=""
UNMUTED_MIC_GLYPH=""

RED=$(xrdb -query | grep "*.nord11:" | cut -f 2)
GREEN=$(xrdb -query | grep "*.nord14:" | cut -f 2)

MUTED_MIC=$(pacmd list-sources | awk '/\*/,EOF {print}' | awk '/muted/ {print $2; exit}')
if [ "$MUTED_MIC" = "yes" ]; then
  MIC_GLYPH=$MUTED_MIC_GLYPH
else
  MIC_GLYPH=$UNMUTED_MIC_GLYPH
fi

if lsof /dev/video0 >/dev/null 2>&1; then
  CAMERA="%{+u}%{u$GREEN} $CAMERA_GLYPH %{u-}"

else
  CAMERA="%{+u}%{u$RED} $CAMERA_GLYPH %{u-}"
fi

if pacmd list-sources 2>&1 | grep -q RUNNING; then
  MIC=%{F$ACTIVE_COLOUR}${MIC_GLYPH}
else
  MIC=%{F$INACTIVE_COLOUR}${MIC_GLYPH}
fi

echo "$CAMERA"
