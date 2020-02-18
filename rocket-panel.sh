#!/bin/bash



# TLB combinations
L1_SETS=("1"    "1"     "1"     "1"     "1"     "1"     "32"    "32")
L1_WAYS=("32"   "32"    "32"    "32"    "32"    "32"    "4"     "8")
L2_SETS=("16"   "16"    "128"   "128"   "256"   "256"   "256"   "256")
L2_WAYS=("4"     "8"    "4"     "8"     "4"     "8"     "4"     "8")


BASE_DIR=$(pwd)
ROCKET_DIR=$BASE_DIR/../rocket-chip/src/main/scala/rocket
HCACHE=$ROCKET_DIR/HellaCache.scala
RCORE=$ROCKET_DIR/RocketCore.scala
PTWALK=$ROCKET_DIR/PTW.scala

MAKEFRAG=$BASE_DIR/../common/Makefrag.zcu
BOOT_BIN=$BASE_DIR/petalinux_proj/images/linux/BOOT.BIN
GEN_BITSTREAM=$BASE_DIR/../../generated-bitstream

for i in ${!L1_SETS[@]} 
do
	NL1_SETS=${L1_SETS[$i]} 
	NL1_WAYS=${L1_WAYS[$i]} 
	NL2_SETS=${L2_SETS[$i]} 
	NL2_WAYS=${L2_WAYS[$i]} 

	echo "L1:" $NL1_SETS $NL1_WAYS 
	echo "L2:" $NL2_SETS $NL2_WAYS
	sed -i "/nTLBSets/c\    nTLBSets: Int = $NL1_SETS," $HCACHE
	sed -i "/nTLBWays/c\    nTLBWays: Int = $NL1_WAYS," $HCACHE
	sed -i "/nL2TLBEntries/c\  nL2TLBEntries: Int = $NL2_WAYS," $RCORE
	sed -i "/val nL2TLBSets/c\    val nL2TLBSets = $NL2_SETS" $PTWALK


	sh generate-bitstream.sh
	
	cp $BOOT_BIN $GEN_BITSTREAM/BOOT.BIN_L1_${NL1_SETS}-${NL1_WAYS}_L2_${NL2_SETS}-${NL2_WAYS} 
	
	mv zcu102_rocketchip_ZynqConfig zcu102_rocketchip_ZynqConfig_L1_${NL1_SETS}-${NL1_WAYS}_L2_${NL2_SETS}_${NL2_WAYS} 
	rm -rf petalinux_proj
done

# Remove Vivado logs
rm vivado*


