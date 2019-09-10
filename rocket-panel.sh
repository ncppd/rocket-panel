#!/bin/bash

L1=("32" "32" "64" "64" "128" "128" "256" "256" "512" "512" "512" "1024") 
L2=("64" "128" "128" "256" "256" "512" "512" "1024" "1024" "1024" "2048" "4096")
PTWC=("8" "8" "16" "16" "32" "32" "64" "64" "64" "128" "256" "512")

BASE_DIR=$(pwd)
ROCKET_DIR=$BASE_DIR/../rocket-chip/src/main/scala/rocket
HCACHE=$ROCKET_DIR/HellaCache.scala
RCORE=$ROCKET_DIR/RocketCore.scala
PTWALK=$ROCKET_DIR/PTW.scala

BOOT_BIN=$BASE_DIR/petalinux_proj/images/linux/BOOT.BIN
GEN_BITSTREAM=$BASE_DIR/../../generated-bitstream

for i in ${!L1[@]} 
do
	NL1=${L1[$i]} 
	NL2=${L2[$i]} 
	NPTWC=${PTWC[$i]}

	echo $NL1 $NL2 $NPTWC
	sed -i "/nTLBEntries/c\    nTLBEntries: Int = $NL1," $HCACHE
	sed -i "/nL2TLBEntries/c\  nL2TLBEntries: Int = $NL2," $RCORE
	sed -i "119s/.*/    val size = $NPTWC/" $PTWALK

	sh generate-bitstream.sh
	
	cp $BOOT_BIN $GEN_BITSTREAM/BOOT.BIN_${NL1}_${NL2}_${NPTWC}
done


