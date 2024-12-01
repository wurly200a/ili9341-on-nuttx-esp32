#!/bin/bash

BUILD_PREFIX_DIR=.

BOARD=esp32-devkitc
CONFIG=wifi
#CONFIG=nsh

#BOARD=sim
#CONFIG=vpnkit

NUTTX_DIR=${BUILD_PREFIX_DIR}/nuttx
NUTTX_GIT_URL=https://github.com/apache/incubator-nuttx
NUTTX_GIT_TAG=releases/12.6
#NUTTX_GIT_TAG=master

NUTTX_APPS_DIR=${BUILD_PREFIX_DIR}/apps
NUTTX_APPS_GIT_URL=https://github.com/apache/incubator-nuttx-apps
NUTTX_APPS_GIT_TAG=releases/12.6
#NUTTX_APPS_GIT_TAG=master

NUTTX_APPS_EXTERNAL_DIR=${NUTTX_APPS_DIR}/external

MY_APP_NAME=hello
MY_APP_DIR=${BUILD_PREFIX_DIR}/${MY_APP_NAME}
MY_APP_EXTERNAL_DIR=${NUTTX_APPS_EXTERNAL_DIR}/${MY_APP_NAME}

function setenv() {
    HOME=/home/builder
    PATH=${ESP_PATH}:${HOME}/.local/bin/:${PATH}
}

function configure() {
    # clone incubator-nuttx
    if [ ! -d ${NUTTX_DIR} ]; then
        mkdir -p $(dirname ${NUTTX_DIR})
        git clone ${NUTTX_GIT_URL} -b ${NUTTX_GIT_TAG} ${NUTTX_DIR}
    fi

    # clone incubator-nuttx-apps
    if [ ! -d ${NUTTX_APPS_DIR} ]; then
        mkdir -p $(dirname ${NUTTX_APPS_DIR})
        git clone ${NUTTX_APPS_GIT_URL} -b ${NUTTX_APPS_GIT_TAG} ${NUTTX_APPS_DIR}
    fi

#    cp replacement_files/boards.xtensa.esp32.esp32-devkitc.src.esp32_w5500.c ${NUTTX_DIR}/boards/xtensa/esp32/esp32-devkitc/src/esp32_w5500.c

    cd nuttx
    ./tools/configure.sh -l ${BOARD}:${CONFIG}

    #
    # Debug Options
    #
    kconfig-tweak --enable DEBUG_FEATURES

    #
    # Debug SYSLOG Output Controls
    #
    kconfig-tweak --enable DEBUG_ERROR
    kconfig-tweak --enable DEBUG_WARN
    kconfig-tweak --enable DEBUG_INFO
    kconfig-tweak --enable DEBUG_ASSERTIONS

    #
    # Subsystem Debug Options
    #
#    kconfig-tweak --disable DEBUG_FS
#    kconfig-tweak --disable DEBUG_FS_ERROR
#    kconfig-tweak --disable DEBUG_FS_WARN
#    kconfig-tweak --disable DEBUG_FS_INFO

    kconfig-tweak --enable DEBUG_GRAPHICS
    kconfig-tweak --enable DEBUG_GRAPHICS_ERROR
    kconfig-tweak --enable DEBUG_GRAPHICS_WARN
    kconfig-tweak --enable DEBUG_GRAPHICS_INFO

    #
    # Driver Debug Options
    #
#    kconfig-tweak --enable DEBUG_I2C
#    kconfig-tweak --enable DEBUG_I2C_ERROR
#    kconfig-tweak --enable DEBUG_I2C_WARN
#    kconfig-tweak --enable DEBUG_I2C_INFO

    kconfig-tweak --enable DEBUG_SPI
    kconfig-tweak --enable DEBUG_SPI_ERROR
    kconfig-tweak --enable DEBUG_SPI_WARN
    kconfig-tweak --enable DEBUG_SPI_INFO

    kconfig-tweak --enable DEBUG_GPIO
    kconfig-tweak --enable DEBUG_GPIO_ERROR
    kconfig-tweak --enable DEBUG_GPIO_WARN
    kconfig-tweak --enable DEBUG_GPIO_INFO

    kconfig-tweak --enable DEBUG_ASSERTIONS
    kconfig-tweak --enable DEBUG_SYMBOLS

    #
    # System Logging
    #

    #
    # SYSLOG channels
    #
    kconfig-tweak --set-str SYSLOG_DEVPATH "/dev/console"
    kconfig-tweak --enable SYSLOG_CONSOLE

#    # hello
#    kconfig-tweak --enable APP_HELLO
#    kconfig-tweak --set-val APP_HELLO_PRIORITY 100
#    kconfig-tweak --set-val APP_HELLO_STACKSIZE 2048

#    System Type  --->
#      ESP32 Chip Selection (ESP32-WROVER)  --->
    kconfig-tweak --enable ARCH_CHIP_ESP32WROVER

#      ESP32 Peripheral Selection  --->
#        [*] SPI 2
#        [ ] SPI 3
#        [*] SPI RAM
    kconfig-tweak --enable ESP32_SPI2
    kconfig-tweak --enable ESP32_SPIRAM

#      SPI Configuration  --->
#        [ ] SPI software CS
#        [ ]   User defined CS
#        [ ] SPI2 use DMA
#        (2) SPI master DMA description number
#        (15) SPI2 CS Pin
#        (14) SPI2 CLK Pin
#        (13) SPI2 MOSI Pin
#        (12) SPI2 MISO Pin
#        SPI3 master I/O mode (Read & Write)  --->
#          (X) Read & Write
    kconfig-tweak --enable ESP32_SPI_SWCS
    kconfig-tweak --disable ESP32_SPI2_DMA
    kconfig-tweak --set-val ESP32_SPI2_CSPIN 15
    kconfig-tweak --set-val ESP32_SPI2_CLKPIN 18  # default 14
    kconfig-tweak --set-val ESP32_SPI2_MOSIPIN 23 # default 13
    kconfig-tweak --set-val ESP32_SPI2_MISOPIN 19 # default 12
    kconfig-tweak --enable ESP32_SPI2_MASTER_IO_RW

#      SPI Configuration  --->
#        (14) SPI3 CS Pin
#        (18) SPI3 CLK Pin
#        (23) SPI3 MOSI Pin
#        (19) SPI3 MISO Pin
#        SPI3 master I/O mode (Read & Write)  --->
#          (X) Read & Write
#    kconfig-tweak --set-val ESP32_SPI3_CSPIN 14
#    kconfig-tweak --set-val ESP32_SPI3_CLKPIN 18
#    kconfig-tweak --set-val ESP32_SPI3_MOSIPIN 23
#    kconfig-tweak --set-val ESP32_SPI3_MISOPIN 19
#    kconfig-tweak --enable ESP32_SPI3_MASTER_IO_RW


#        [*] I2C 0
#        [ ] I2C 1
#    kconfig-tweak --enable ESP32_I2C
#    kconfig-tweak --enable ESP32_I2C0
#
#      Memory Configuration  --->
#        *** Additional Heaps ***
#            SPI RAM heap function (Separated userspace heap)  --->
#        [ ] Use the rest of IRAM as a separete heap
    kconfig-tweak --disable ESP32_SPIRAM_COMMON_HEAP
    kconfig-tweak --enable ESP32_SPIRAM_USER_HEAP

# CONFIG_MOSI_GPIO=23
# CONFIG_SCLK_GPIO=18
# CONFIG_TFT_CS_GPIO=14
# CONFIG_DC_GPIO=27
# CONFIG_RESET_GPIO=33
# CONFIG_BL_GPIO=32
# # CONFIG_INVERSION is not set
# # CONFIG_RGB_COLOR is not set
# CONFIG_XPT2046_DISABLE=y
# # CONFIG_XPT2046_ENABLE_SAME_BUS is not set
# # CONFIG_XPT2046_ENABLE_DIFF_BUS is not set
# CONFIG_SPI2_HOST=y





#      SPI Flash Configuration  --->
#        (0x300000) Storage MTD base adddress in SPI Flash
#        (0x100000) Storage MTD size in SPI Flash
#        [*] Support PSRAM As Task Stack
#        [*] Create MTD partitions from Partition Table
    kconfig-tweak --set-val ESP32_STORAGE_MTD_OFFSET 0x300000
    kconfig-tweak --set-val ESP32_STORAGE_MTD_SIZE 0x100000
    kconfig-tweak --enable ESP32_SPI_FLASH_SUPPORT_PSRAM_STACK
    kconfig-tweak --enable ESP32_PARTITION_TABLE
#
#      SPI RAM Configuration  --->
#        Type of SPI RAM chip in use (Auto-detect)  --->
#
#
#    Board Selection  --->
#      *** Board Common Options ***
#      [*]   Mount SPI Flash MTD on bring-up (LittleFS)
    kconfig-tweak --enable ESP32_SPIFLASH_LITTLEFS
#
#    RTOS Features  --->
#      Tasks and Scheduling  --->
#        [*] Auto-mount etc banked-in ROMFS image  ----
#    kconfig-tweak --enable ETC_ROMFS
#

#
#    Message Queue Options
#
    kconfig-tweak --set-val MQ_MAXMSGSIZE 64

#    Device Drivers  --->
#      [*] I2C Driver Support  --->
#    kconfig-tweak --enable I2C
#    kconfig-tweak --enable I2C_DRIVER

#      -*- SPI Driver Support  --->
#        [*] SPI exchange
#        [*] SPI CMD/DATA
    kconfig-tweak --enable SPI
    kconfig-tweak --enable SPI_EXCHANGE
    kconfig-tweak --enable SPI_CMDDATA
#
#      [*] Video Device Support  --->
#        [*] Framebuffer character driver
#
#
#      [*] LCD Driver Support  --->
#        [*] Graphic LCD Driver Support  --->
#          [*] LCD framebuffer front end
#          [*] LCD driver selection  --->
#            [*] Generic SPI Interface Driver (for ILI9341 or others)
#            (1) Number of SSD1306 displays 
#                SSD1306 Interface (SSD1306 on I2C Interface)  --->

    kconfig-tweak --enable LCD
    kconfig-tweak --enable LCD_PACKEDMSFIRST
    kconfig-tweak --enable LCD_FRAMEBUFFER

    # LCD driver selection
    kconfig-tweak --set-val LCD_MAXCONTRAST 63
    kconfig-tweak --set-val LCD_MAXPOWER 1
    kconfig-tweak --enable LCD_ILI9341

    kconfig-tweak --enable LCD_ILI9341_IFACE0
    kconfig-tweak --enable LCD_ILI9341_IFACE0_LANDSCAPE
    kconfig-tweak --enable LCD_ILI9341_IFACE0_RGB565
    kconfig-tweak --enable LCD_LCDDRV_SPIIF
    kconfig-tweak --set-val LCD_LCDDRV_SPEED 10000000



    kconfig-tweak --enable LCD_LANDSCAPE

#    Timer Driver Support
    kconfig-tweak --enable FB_UPDATE
#
#
#
#    Networking Support  --->
#
#
#    File Systems  --->
#      [*] ROMFS file system
#    kconfig-tweak --enable FS_ROMFS
#
#    Graphic Support  --->
#      [*] NX Graphics

    kconfig-tweak --enable NX
    kconfig-tweak --enable NX_LCDDRIVER
    kconfig-tweak --set-val NX_NDISPLAYS 1
    kconfig-tweak --set-val NX_NPLANES 1
    kconfig-tweak --enable NX_NOCURSOR
    kconfig-tweak --set-val NX_BGCOLOR 0x0

# Supported Pixel Depths
    kconfig-tweak --disable NX_DISABLE_1BPP
    kconfig-tweak --enable NX_DISABLE_2BPP
    kconfig-tweak --enable NX_DISABLE_4BPP
    kconfig-tweak --enable NX_DISABLE_8BPP
    kconfig-tweak --enable NX_DISABLE_16BPP
    kconfig-tweak --enable NX_DISABLE_24BPP
    kconfig-tweak --enable NX_DISABLE_32BPP
    kconfig-tweak --enable NX_PACKEDMSFIRST

#
# Input Devices
#
    kconfig-tweak --enable NX_XYINPUT_NONE

#
# Framed Window Borders
#
    kconfig-tweak --set-val NXTK_BORDERWIDTH 4
    kconfig-tweak --enable NXTK_DEFAULT_BORDERCOLORS

#
# NX server options
#
    kconfig-tweak --enable NX_BLOCKING
    kconfig-tweak --set-val NX_MXSERVERMSGS 32
    kconfig-tweak --set-val NX_MXCLIENTMSGS 16

    kconfig-tweak --set-val NXSTART_SERVERPRIO 110
    kconfig-tweak --set-val NXSTART_SERVERSTACK 8192
    kconfig-tweak --set-val NXSTART_DEVNO 0
    kconfig-tweak --enable NXFONTS

#
# Font Selections
#
    kconfig-tweak --set-val NXFONTS_CHARBITS 7
    kconfig-tweak --disable NXFONT_MONO5X8
    kconfig-tweak --disable NXFONT_SANS20X26
    kconfig-tweak --enable NXFONT_SANS28X37
    kconfig-tweak --disable NXFONT_SANS39X48
    kconfig-tweak --disable NXFONT_PIXEL_LCD_MACHINE
    kconfig-tweak --disable NXFONT_TOM_THUMB_4X6

#
# Font Cache Pixel Depths
#
    kconfig-tweak --disable NXFONTS_DISABLE_1BPP
    kconfig-tweak --enable NXFONTS_DISABLE_2BPP
    kconfig-tweak --enable NXFONTS_DISABLE_4BPP
    kconfig-tweak --enable NXFONTS_DISABLE_8BPP
    kconfig-tweak --enable NXFONTS_DISABLE_16BPP
    kconfig-tweak --enable NXFONTS_DISABLE_24BPP
    kconfig-tweak --enable NXFONTS_DISABLE_32BPP
    kconfig-tweak --enable NXFONTS_PACKEDMSFIRST
    kconfig-tweak --enable NXGLIB

#    Memory Management
#      (0x3F800000) Start address of second user heap region
#      (4194304) Start address of second user heap region
    kconfig-tweak --set-val HEAP2_BASE 0x3F800000
    kconfig-tweak --set-val HEAP2_SIZE 4194304
#
#    Application Configuration  --->
#      Examples  --->
#        [*] Framebuffer driver example
#
#      Network Utiliteis  --->
#        -*- Network initialization
#              IP Address Configuration  --->
#                [*] Use DHCP to get IP address
#          [*] Use DNS
    kconfig-tweak --enable NETINIT_DHCPC
    kconfig-tweak --enable NETINIT_DNS
#

#      System Libraries and NSH Add-Ons  --->
#        [*] SPI tool  --->
    kconfig-tweak --enable SYSTEM_SPITOOL
    kconfig-tweak --set-str SPITOOL_PROGNAME "spi"
    kconfig-tweak --set-val SPITOOL_PRIORITY 100
    kconfig-tweak --set-val SPITOOL_STACKSIZE 4096
    kconfig-tweak --set-val SPITOOL_MINBUS 0
    kconfig-tweak --set-val SPITOOL_MAXBUS 3
    kconfig-tweak --set-val SPITOOL_DEFFREQ 4000000
    kconfig-tweak --set-val SPITOOL_DEFCMD 0
    kconfig-tweak --set-val SPITOOL_DEFMODE 0
    kconfig-tweak --set-val SPITOOL_DEFWIDTH 8
    kconfig-tweak --set-val SPITOOL_DEFWORDS 1

#    kconfig-tweak --enable PSEUDOFS_SOFTLINKS
#    kconfig-tweak --enable FS_RAMMAP

#    #------------------------------------------------------------#
#    kconfig-tweak --enable EXAMPLES_NXDEMO
#
#    kconfig-tweak --set-val EXAMPLES_NXDEMO_VPLANE 0
#    kconfig-tweak --set-val EXAMPLES_NXDEMO_DEVNO 0
#    kconfig-tweak --set-val EXAMPLES_NXDEMO_BPP 1
#
#    kconfig-tweak --disable EXAMPLES_NXDEMO_DEFAULT_COLORS
#    kconfig-tweak --set-val EXAMPLES_NXDEMO_BGCOLOR 0x0
#    kconfig-tweak --disable EXAMPLES_NXDEMO_EXTERNINIT
##    #------------------------------------------------------------#
#    kconfig-tweak --enable EXAMPLES_NXHELLO
#    kconfig-tweak --set-str EXAMPLES_NXHELLO_PROGNAME "nxhello"
#    kconfig-tweak --set-val EXAMPLES_NXHELLO_PRIORITY 100
#    kconfig-tweak --set-val EXAMPLES_NXHELLO_STACKSIZE 4096
#    kconfig-tweak --set-val EXAMPLES_NXHELLO_BPP 1
#
#    # Example Color Configuration
#    kconfig-tweak --enable EXAMPLES_NXHELLO_DEFAULT_COLORS
#
#    # Example Font Configuration
#    kconfig-tweak --enable EXAMPLES_NXHELLO_DEFAULT_FONT
#
#    # NX Server Options
#    kconfig-tweak --set-val EXAMPLES_NXHELLO_LISTENER_STACKSIZE 4096
#    kconfig-tweak --set-val EXAMPLES_NXHELLO_CLIENTPRIO 100
#    kconfig-tweak --set-val EXAMPLES_NXHELLO_SERVERPRIO 120
#    kconfig-tweak --set-val EXAMPLES_NXHELLO_LISTENERPRIO 80
#    #------------------------------------------------------------#
##    kconfig-tweak --disable EXAMPLES_NXIMAGE
##    kconfig-tweak --set-str EXAMPLES_NXIMAGE_PROGNAME "nximage"
##    kconfig-tweak --set-val EXAMPLES_NXIMAGE_PRIORITY 100
##    kconfig-tweak --set-val EXAMPLES_NXIMAGE_STACKSIZE 4096
##    kconfig-tweak --set-val EXAMPLES_NXIMAGE_BPP 8
##    kconfig-tweak --enable EXAMPLES_NXIMAGE_GREYSCALE
##    kconfig-tweak --enable EXAMPLES_NXIMAGE_XSCALE1P0
##    kconfig-tweak --enable EXAMPLES_NXIMAGE_YSCALE1P0
##
##    # NX Server Options
##    kconfig-tweak --set-val EXAMPLES_NXIMAGE_LISTENER_STACKSIZE 4096
##    kconfig-tweak --set-val EXAMPLES_NXIMAGE_CLIENTPRIO 100
##    kconfig-tweak --set-val EXAMPLES_NXIMAGE_SERVERPRIO 120
##    kconfig-tweak --set-val EXAMPLES_NXIMAGE_LISTENERPRIO 80
#    #------------------------------------------------------------#
#    kconfig-tweak --enable EXAMPLES_NXLINES
#    kconfig-tweak --set-str EXAMPLES_NXLINES_PROGNAME "nxlines"
#    kconfig-tweak --set-val EXAMPLES_NXLINES_PRIORITY 100
#    kconfig-tweak --set-val EXAMPLES_NXLINES_STACKSIZE 4096
#    kconfig-tweak --disable EXAMPLES_NXLINES_DEFAULT_COLORS
#    kconfig-tweak --set-val EXAMPLES_NXLINES_BGCOLOR 0x00
#    kconfig-tweak --set-val EXAMPLES_NXLINES_LINEWIDTH 16
#    kconfig-tweak --set-val EXAMPLES_NXLINES_LINECOLOR 0x01
#    kconfig-tweak --set-val EXAMPLES_NXLINES_BORDERWIDTH 16
#    kconfig-tweak --set-val EXAMPLES_NXLINES_BORDERCOLOR 0x01
#    kconfig-tweak --set-val EXAMPLES_NXLINES_CIRCLECOLOR 0x01
#    kconfig-tweak --set-val EXAMPLES_NXLINES_BPP 1
#
#    # NX Server Options
#    kconfig-tweak --set-val EXAMPLES_NXLINES_LISTENER_STACKSIZE 4096
#    kconfig-tweak --set-val EXAMPLES_NXLINES_CLIENTPRIO 100
#    kconfig-tweak --set-val EXAMPLES_NXLINES_SERVERPRIO 120
#    kconfig-tweak --set-val EXAMPLES_NXLINES_LISTENERPRIO 80
#    #------------------------------------------------------------#
#    kconfig-tweak --enable EXAMPLES_NXTEXT
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_BPP 1        
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_BMCACHE 128  
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_GLCACHE 16   
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_LINESPACING 2
#
#    kconfig-tweak --disable EXAMPLES_NXTEXT_DEFAULT_COLORS
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_BGCOLOR 0x0    
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_BGFONTCOLOR 0x1
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_PUCOLOR 0x1    
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_PUFONTCOLOR 0x1
#
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_BGFONTID 0
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_PUFONTID 1
#
#    # NX Server Options
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_STACKSIZE 4096 
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_LISTENERPRIO 80
#    kconfig-tweak --set-val EXAMPLES_NXTEXT_CLIENTPRIO 100 
#    #------------------------------------------------------------#

    make olddefconfig

#######################################################################



#######################################################################

    cd ..
}

function menuconfig() {
    cd ${NUTTX_DIR}
    make menuconfig
    cd ..
}

function clean() {
    cd ${NUTTX_DIR}
#    make clean_context all
    make clean
    cd ..
}

function create_etc_romfs() {
    cd ${NUTTX_DIR}

    cd ..
}

function build() {
    cd ${NUTTX_DIR}
    make -j$(nproc) ESPTOOL_BINDIR=. V=1
    cd ..
}

function build_bootloader() {
    if [ "${BOARD}" != "sim" ]; then
        current_dir=$(pwd)
        cd ${NUTTX_DIR}
        make bootloader
        rm partition-table-esp32.bin # avoid to use this
        cd ${current_dir}
    fi
}

function build_partition_table() {
    cd ${NUTTX_DIR}
    gen_esp32part.py ../partition/esp32-partitions.csv partition-table-esp32.bin
    cd ..
}

function allclean() {
    echo "Cleaning up generated files..."
    if [ -d ${NUTTX_DIR} ]; then
        rm -rf ${NUTTX_DIR}
    fi
    if [ -d ${NUTTX_APPS_DIR} ]; then
        rm -rf ${NUTTX_APPS_DIR}
    fi
}

if [ -n "$ESP_IDF_VERSION" ]; then
    echo "ESP_IDF_VERSION=${ESP_IDF_VERSION}"
else
    echo "This script is expected to run using docker container which included ESP_IDF"
    echo "Please run:"
    echo "docker run --rm -it --user 1000:1000 -v \${PWD}:/mnt/work -w /mnt/work ghcr.io/wurly200a/builder-esp32/esp-idf-v5.3:latest"
    echo "then"
    echo ". /opt/esp-idf/export.sh"
    exit
fi

case "$1" in
    allclean)
        setenv
        clean
        allclean
        ;;
    clean)
        setenv
        clean
        ;;
    configure)
        setenv
        configure
        ;;
    menuconfig)
        setenv
        menuconfig
        ;;
    build)
        setenv
        build
        ;;
    etcromfs)
        setenv
        create_etc_romfs
        ;;
    bootloader)
        setenv
        build_bootloader
        ;;
    partition)
        setenv
        build_partition_table
        ;;
    *)
        setenv
        configure
        build_bootloader
        build_partition_table
        build
        ;;
esac
