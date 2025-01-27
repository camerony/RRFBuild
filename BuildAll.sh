#!/bin/sh
beginTime=$(date +%s)
VER=`awk 'sub(/.*MAIN_VERSION/,""){print $1}' RepRapFirmware/src/Version.h  | awk 'gsub(/"/, "", $1)'`
OUTPUT=releases/${VER}/
rm -rf $OUTPUT
./BuildRelease.sh Debug STM32 STM32H7 STM32H743 COMBINED base_stm32h743
./BuildRelease.sh Debug STM32 STM32H7 STM32H723 COMBINED base_stm32h723
./BuildRelease.sh Debug STM32 STM32F4 "" COMBINED base_stm32f4
./BuildIAPRelease.sh Debug STM32 STM32H7 STM32H723 COMBINED stm32h723_iap_SBC
./BuildIAPRelease.sh Debug STM32 STM32H7 STM32H743 COMBINED stm32h743_iap_SBC
./BuildIAPRelease.sh Debug STM32 STM32F4 "" COMBINED stm32f4_iap_SBC
./BuildIAPBLRelease.sh Debug STM32 STM32H7 STM32H743 2 stm32h743_bootloader_2
./BuildExpRelease.sh Debug RP2040 FLY36RRF 0 "-DUSE_PICOCAN" "FLY36RRF_picocan"
./BuildExpRelease.sh Debug RP2040 FLY36RRF 1 "-DUSE_SPICAN" "FLY36RRF"
./BuildExpRelease.sh Debug RP2040 FLYSB2040V1_0 0 "-DUSE_PICOCAN" "FLYSB2040V1_0_picocan"
./BuildExpRelease.sh Debug RP2040 FLYSB2040V3_0 300 "-DUSE_SPICAN" "SB2040MAX3"
./BuildExpRelease.sh Debug RP2040 FLYSB2040V3_0 301 "-DUSE_SPICAN" "SB2040PROMAX3"
./BuildExpRelease.sh Debug RP2040 SHT36 300 "-DUSE_SPICAN" "SHT36V3"
./BuildExpRelease.sh Debug RP2040 SHT36 301 "-DUSE_SPICAN" "SHT36MAX3"
./BuildExpRelease.sh Debug RP2040 MKSTHR3642 1 "-DUSE_PICOCAN" "MKSTHR3642v1_0_picocan"
./BuildExpRelease.sh Debug RP2040 PITBV1_0 0 "-DUSE_PICOCAN" "PITBV1_0_picocan"
./BuildExpRelease.sh Debug RP2040 PITBV2_0 0 "-DUSE_SPICAN" "PITBV2_0"
./BuildExpRelease.sh Debug RP2040 STRIDEMAXV2_0 0 "-DUSE_SPICAN" "STRIDEMAXV2_0"
for oem in boards/*; do
    for board in ${oem}/*_h743; do
        ./BuildBoardRelease.sh Debug STM32H7 COMBINED $(basename $oem) $(basename $board) base_stm32h743 firmware_$(basename $board) stm32h743_iap_SBC
    done
done
for oem in boards/*; do
    for board in ${oem}/*_h723; do
        ./BuildBoardRelease.sh Debug STM32H723 COMBINED $(basename $oem) $(basename $board) base_stm32h723 firmware_$(basename $board) stm32h723_iap_SBC
    done
done
for oem in boards/*; do
    for board in ${oem}/*_f4; do
    ./BuildBoardRelease.sh Debug STM32F4 COMBINED $(basename $oem) $(basename $board) base_stm32f4 firmware_$(basename $board) stm32f4_iap_SBC
    done
done
WIFIVER=`awk 'sub(/.*VERSION_MAIN/,""){print $1}' WiFiSocketServerRTOS/src/Config.h  | awk 'gsub(/"/, "", $1)'`
mkdir -p ${OUTPUT}/wifi/
cp WiFiSocketServerRTOS/releases/${WIFIVER}/*.bin ${OUTPUT}/wifi
./BuildDWC.sh
./BuildZips.sh Debug

echo "Release dir is ${OUTPUT}"
echo -n "Number of base files: "
find ${OUTPUT}/base/ -name "*.bin" | wc -l
echo -n "Number of expansion boards: "
find ${OUTPUT}/expansion/ -name "*.*" | wc -l
echo -n "Number of board configurations: "
find boards -name "rrfboot.txt" | wc -l
echo -n "Number of boards created: "
find ${OUTPUT}/mainboard/ -name "*.zip" | wc -l
echo -n "Number of WiFi Modules: "
find ${OUTPUT}/wifi/ -name "*.bin" | wc -l
endTime=$(date +%s)
echo "Zip file sizes:"
ls -gho ${OUTPUT}/*.zip
echo -n "WiFi Zip file count: "
/c/Windows/SysWOW64/tar.exe tvfn ${OUTPUT}/STM32RepRapFirmwareWiFi.zip | wc -l
echo -n "SBC Zip file count: "
/c/Windows/SysWOW64/tar.exe tvfn ${OUTPUT}/STM32RepRapFirmwareSBC.zip | wc -l
echo -n "Build time: "
date -d@$(expr $endTime - $beginTime) -u +%H:%M:%S