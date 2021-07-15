#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Please specify the fgapplication folder number"
    exit 1
fi
DEPLOY_LOCATION="/cygdrive/c/src/$1/fgapplication/External/Cal/"
cp Build/SteehlIarDebug/Cam.a "$DEPLOY_LOCATION/CortexM4-Iar/"
cp Build/SteehlMsvcDebug/Cam.lib "$DEPLOY_LOCATION/Win32/"
echo "Deployed to $DEPLOY_LOCATION"
