#!/bin/bash

# Different TLB combinations
#L1SETS=("32" "32" "64" "64" "128" "128" "256" "256" "512" "512") 
#L2=("64" "128" "128" "256" "256" "512" "512" "1024" "1024" "1024")
#PTWC=("8" "8" "16" "16" "32" "32" "64" "64" "64" "128")

L1SETS=("512" "1" "8")
L1WAYS=("1" "512" "64")
L2=("0" "0" "0" )
PTWC=("8" "8" "8")


# Timing analysis on the L1SETS TLB
#L1SETS=("32" "64" "128" "256" "512") 
#L2=("0" "0" "0" "0" "0")
#PTWC=("8" "8" "8" "8" "8")

# Timing analysis on the L2 TLB
#L1SETS=("32" "32" "32" "32" "32")
#L2=("32" "64" "128" "256" "512") 
#PTWC=("8" "8" "8" "8" "8")

BASE_DIR=$(pwd)
ROCKET_DIR=$BASE_DIR/../rocket-chip/src/main/scala/rocket
HCACHE=$ROCKET_DIR/HellaCache.scala
RCORE=$ROCKET_DIR/RocketCore.scala
PTWALK=$ROCKET_DIR/PTW.scala

MAKEFRAG=$BASE_DIR/../common/Makefrag.zcu
BOOT_BIN=$BASE_DIR/petalinux_proj/images/linux/BOOT.BIN
GEN_BITSTREAM=$BASE_DIR/../../generated-bitstream

for i in ${!L1SETS[@]} 
do
	NL1SETS=${L1SETS[$i]} 
	NL1WAYS=${L1WAYS[$i]} 
	NL2=${L2[$i]} 
	NPTWC=${PTWC[$i]}

	echo $NL1SETS $NL1WAYS $NL2 $NPTWC
	sed -i "/nTLBSets/c\    nTLBSets: Int = $NL1SETS," $HCACHE
	sed -i "/nTLBWays/c\    nTLBWays: Int = $NL1WAYS," $HCACHE
	sed -i "/nL2TLBEntries/c\  nL2TLBEntries: Int = $NL2," $RCORE
	sed -i "119s/.*/    val size = $NPTWC/" $PTWALK

	sh generate-bitstream.sh
	
	cp $BOOT_BIN $GEN_BITSTREAM/BOOT.BIN_${NL1SETS}S-${NL1WAYS}W_${NL2}_${NPTWC} 
	
	mv zcu102_rocketchip_ZynqConfig zcu102_rocketchip_ZynqConfig__${NL1SETS}S-${NL1WAYS}W_${NL2}_${NPTWC} 

done

# Remove Vivado logs
rm vivado*


