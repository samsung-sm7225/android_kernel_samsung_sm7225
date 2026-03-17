#!/bin/bash

#
# Custom build script by Chatur27, Gabriel2392 and roynatech2544 @Github - 2022
#
# Modified by Mrsiri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

DIRTY_BUILD=false

# Set default directories
ROOT_DIR=$(pwd)
KERNEL_DIR=$ROOT_DIR

# Set default kernel variables
CORES=$(nproc --all)

# Export commands
export KBUILD_BUILD_USER=Mrsiri
export KBUILD_BUILD_HOST=Mrsiri
export ARCH=arm64

# Get date and time
DATE=$(date +"%m-%d-%y")
BUILD_START=$(date +"%s")

######################### Colours ############################

ON_BLUE=$(echo -e "\033[44m")
RED=$(echo -e "\033[1;31m")
BLUE=$(echo -e "\033[1;34m")
GREEN=$(echo -e "\033[1;32m")
STD=$(echo -e "\033[0m")


####################### Devices List #########################

SM_M236B() {
	DEVICE_NAME_M23="Samsung Galaxy M23/F23 5G"
	CODENAME=SM-M236B
	CONFIG_M23=m23xq.config
	DTBO_M23_DIR=./arch/arm64/boot/dts/samsung/m23/m23xq
	PROJECT_NAME_M23=m23xq
}

SM_A426B() {
	DEVICE_NAME_A42="Samsung Galaxy A42/M42 5G"
	CODENAME=SM-A426B
	CONFIG_A42=a42xq.config
	DTBO_A42_DIR=./arch/arm64/boot/dts/samsung/a42/a42xq
	PROJECT_NAME_A42=a42xq
}

SM_A526B() {
	DEVICE_NAME_A52="Samsung Galaxy A52 5G"
	CODENAME=SM-A526B
	CONFIG_A52=a52xq.config
	DTBO_A52_DIR=./arch/arm64/boot/dts/samsung/a52/a52xq
	PROJECT_NAME_A52=a52xq
}

SM_T736B() {
	DEVICE_NAME_GTS7="Samsung Galaxy Tab S7 FE 5G"
	CODENAME=SM-T736B
	CONFIG_GTS7=gts7xllite.config
	DTBO_GTS7_DIR=./arch/arm64/boot/dts/samsung/gts7/gts7xlllite
	PROJECT_NAME_GTS7=gts7xlllite
}
################### Executable functions #######################

PRINT_BANNER() {
    echo " ${BLUE}"
    echo " #################################################################################### "
    echo " #                              Kernel Compiler v1.0                                # "
    echo " #################################################################################### "
}

DTBO_BUILD() {
	if [[ "$SELECTED_DEVICE" == "1" ]]; then
		$(pwd)/tools/mkdtimg create $(pwd)/out/arch/arm64/boot/dtbo.img --page_size=4096 $(find out/arch/arm64/boot/dts/samsung/m23/m23xq/ -name *.dtbo)
	elif [[ "$SELECTED_DEVICE" == "2" ]]; then
		$(pwd)/tools/mkdtimg create $(pwd)/out/arch/arm64/boot/dtbo.img --page_size=4096 $(find out/arch/arm64/boot/dts/samsung/a42/a42xq/ -name *.dtbo)
	elif [[ "$SELECTED_DEVICE" == "3" ]]; then
		$(pwd)/tools/mkdtimg create $(pwd)/out/arch/arm64/boot/dtbo.img --page_size=4096 $(find out/arch/arm64/boot/dts/samsung/a52/a52xq/ -name *.dtbo)
	else
		$(pwd)/tools/mkdtimg create $(pwd)/out/arch/arm64/boot/dtbo.img --page_size=4096 $(find out/arch/arm64/boot/dts/samsung/gts7/gts7xllite/ -name *.dtbo)
	fi
	set +x
}

CLANG_BUILD() {
	CLANG="${HOME}/linux-x86-main/clang-r487747c/bin"
	export CLANG_TRIPLE=aarch64-linux-gnu-
	export PATH="$CLANG:$PATH"
	set -x
	make -j$CORES O=out ARCH=arm64 SUBARCH=arm64 CC=clang LLVM_IAS=1 LLVM=1 vendor/lito-perf_defconfig \
	vendor/samsung/lito-sec-common.config \
	vendor/samsung/$SELECTED_CONFIG > /dev/null
	make -j$CORES O=out \
	ARCH=arm64 \
	SUBARCH=arm64 \
	CC=clang \
	LLVM_IAS=1 LLVM=1
}

DISPLAY_ELAPSED_TIME() {
	# Find out how much time build has taken
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))

	BUILD_SUCCESS=$?
	if [ $BUILD_SUCCESS != 0 ]; then
		echo " ${RED}Error: Build failed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset ${STD}"
		exit
	fi

	echo -e " ${GREEN}Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset ${STD}"
	sleep 1
}

CHECKOUT_DEVICES() {
	SM_M236B
	SM_A426B
	SM_A526B
	SM_T736B
}

BUILD_KERNEL() {
	CHECKOUT_DEVICES
	while true; do
    		echo "Select device to build kernel:"
    		echo "  1) Galaxy M23 5G"
    		echo "  2) Galaxy A42 5G"
		echo "  3) Galaxy A52 5G"
		echo "  4) Galaxy Tab S7 FE"
    		read -p "Enter choice [1 to 4]: " choice
    		case $choice in
        		1 ) 
            		    SELECTED_CONFIG=$CONFIG_M23
			    SELECTED_DEVICE=1
			    SELECTED_DEVICE_NAME=$DEVICE_NAME_M23
            		    echo -e "${GREEN}You selected: ($SELECTED_CONFIG)${STD}"
            		    break 
            		    ;;
        		2 ) 
            		    SELECTED_CONFIG=$CONFIG_A42
			    SELECTED_DEVICE=2
			    SELECTED_DEVICE_NAME=$DEVICE_NAME_A42
            		    echo -e "${GREEN}You selected: ($SELECTED_CONFIG)${STD}"
            		    break 
            		    ;;
			3 ) 
            		    SELECTED_CONFIG=$CONFIG_A52
			    SELECTED_DEVICE=3
			    SELECTED_DEVICE_NAME=$DEVICE_NAME_A52
            		    echo -e "${GREEN}You selected: ($SELECTED_CONFIG)${STD}"
            		    break 
            		    ;;
			4 ) 
            		    SELECTED_CONFIG=$CONFIG_GTS7
			    SELECTED_DEVICE=4
			    SELECTED_DEVICE_NAME=$DEVICE_NAME_GTS7
            		    echo -e "${GREEN}You selected: ($SELECTED_CONFIG)${STD}"
            		    break 
            		    ;;
        		* ) echo "Invalid input. Please choose a device" ;;
	    	esac
	done
	sleep 0.2
    	PRINT_BANNER
	echo " #                  Compiling kernel for $SELECTED_DEVICE_NAME                # "
	echo " #################################################################################### "
	echo " "
	echo " "
	if [[ -e "out" ]]; then
 		while true; do
     			read -p "${BLUE}Do you wish to continue last build (Dirty build)? (y/n)? ${STD}" yn
     			case $yn in
         			[Yy]* ) DIRTY_BUILD=true; break ;;
         			[Nn]* ) DIRTY_BUILD=false; break ;;
         			* ) echo "Please choose Y or N." ;;
     			esac
 		done
 	fi
	if [[ "$DIRTY_BUILD" == "false" && -e "out" ]]; then
        	rm -rf out
    	fi
	echo " ${BLUE}"
	CLANG_BUILD
	echo " ${STD}"
	DTBO_BUILD
	echo " "
	PRINT_BANNER
	echo "${GREEN}                        Build Complete.                                 "
	echo " "
	DISPLAY_ELAPSED_TIME
	while true; do
    		echo "Build for another device or exit?"
    		echo "  1) Build for another device"
    		echo "  2) Exit"
    		read -p "Enter choice [1 or 2]: " choice
    		case $choice in
        		1 ) 
            		    BUILD_KERNEL
            		    break 
            		    ;;
        		2 ) 
            		    EXIT
            		    break 
            		    ;;
        		* ) echo "Invalid input. Please choose." ;;
	    	esac
	done
}

EXIT() {
	echo "Closing script...."
	sleep 0.3
	exit 0
}

###################### Script starts here #######################
BUILD_KERNEL
