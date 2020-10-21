#!/bin/bash

DEPLOY_LOCATION="/cygdrive/c/src/$1/fgapplication/External/Cal/"
cp Build/SteehlIarDebug/Cam.a "$DEPLOY_LOCATION/CortexM4-Iar/"
cp Build/SteehlMsvcDebug/Cam.lib "$DEPLOY_LOCATION/Win32/"
echo $DEPLOY_LOCATION
