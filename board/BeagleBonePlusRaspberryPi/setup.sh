#
# *VERY* Experimental configuration to test ideas for a true "GENERIC"
# FreeBSD/arm kernel.
#
# This installs all the boot bits for both RaspberryPi and BeagleBone.
# The resulting image can load the kernel (with the appropriate
# board-specific FDT) on either platform.  We don't have a true
# working GENERIC kernel that can actually boot on both platforms yet,
# but that's coming...
#

# XXXXXX BROKEN XXXXX
# 
echo "The BeagleBonePlusRaspberryPi board configuration is very broken."
echo "It has not been updated to the new 'strategy-based' architecture."
exit 1

# This is mostly just a lot of juggling so that the RPi and BBone
# routines see the right BOARDDIR.

MYBOARDDIR=${BOARDDIR}
BEAGLEBONE_BOARDDIR=${BOARDDIR}/../BeagleBone
RASPBERRY_PI_BOARDDIR=${BOARDDIR}/../RaspberryPi

BOARDDIR=${BEAGLEBONE_BOARDDIR}
. ${BEAGLEBONE_BOARDDIR}/setup.sh
BOARDDIR=${RASPBERRY_PI_BOARDDIR}
. ${RASPBERRY_PI_BOARDDIR}/setup.sh
BOARDDIR=${MYBOARDDIR}

KERNCONF=GENERIC

board_check_prerequisites ( ) {
    BOARDDIR=${BEAGLEBONE_BOARDDIR}
    beaglebone_check_prerequisites
    BOARDDIR=${RASPBERRY_PI_BOARDDIR}
    raspberry_pi_check_prerequisites
    BOARDDIR=${MYBOARDDIR}
}

board_build_bootloader ( ) {
    BOARDDIR=${BEAGLEBONE_BOARDDIR}
    beaglebone_build_bootloader
    BOARDDIR=${RASPBERRY_PI_BOARDDIR}
    raspberry_pi_build_bootloader
    BOARDDIR=${MYBOARDDIR}
}

board_partition_image ( ) {
    disk_partition_mbr
    # Raspberry Pi boot loaders require FAT16, so this must be at least 17m
    disk_fat_create 20m 16
    disk_ufs_create
}

board_mount_partitions ( ) {
    disk_fat_mount ${BOARD_BOOT_MOUNTPOINT}
    disk_ufs_mount ${BOARD_FREEBSD_MOUNTPOINT}
}

board_populate_boot_partition ( ) {
    BOARDDIR=${BEAGLEBONE_BOARDDIR}
    beaglebone_populate_boot_partition
    BOARDDIR=${RASPBERRY_PI_BOARDDIR}
    raspberry_pi_populate_boot_partition
    BOARDDIR=${MYBOARDDIR}
}

board_populate_freebsd_partition ( ) {
    generic_board_populate_freebsd_partition
    mkdir ${BOARD_FREEBSD_MOUNTPOINT}/boot/msdos
    freebsd_ubldr_copy_ubldr_help ${BOARD_FREEBSD_MOUNTPOINT}/boot
}
