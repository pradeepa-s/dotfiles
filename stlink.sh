#!/bin/bash

ST_LINK_LOCATION='/cygdrive/c/Program Files (x86)/STMicroelectronics/STM32 ST-LINK Utility/ST-LINK Utility/ST-LINK_CLI.exe'

echo "Programming $1"
"$ST_LINK_LOCATION"

