#!/bin/sh
git tag $1
cd CoreN2G
git tag $1
cd ../RepRapFirmware
git tag $1
cd ../RRFLibraries
git tag $1
cd ../CANlib
git tag $1
cd ../FreeRTOS
git tag $1
cd ../IAP
git tag $1
cd ../Duet3Expansion
git tag $1
#cd ../DuetWebControl
#git tag $1
cd ..
