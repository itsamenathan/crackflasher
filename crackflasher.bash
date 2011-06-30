#!/bin/bash

###########################################################################
#                 CONFIG
# Location of adb
ADB="/home/jimshoe/android-sdk-linux_86/platform-tools/adb"
###########################################################################

# flags
BACKUP=0
DEVICE=0
WIPE=0
RECOVER=0
LIST=0
BOOTLOADER=0
WIPE_SYSTEM=0

EXTCOMMANDS="/tmp/extendedcommand"
BOLD="\033[1m"
NORM="\033[0m"
RED="\033[31m"
GREEN="\033[32m"

if [ $# -eq 0 ]; then
  echo "Usage: ./crackflasher -b -w [num] update.zip update2.zip"
  echo "-b - makes backup in /sdcard/clockworkmod/backup/ named date and is optional"
  echo "-d - device id from adb devices, this will tell this script to send adb commands to only that device"
  echo "-l - list backups in /sdcard/clockworkmod/backup/"
  echo "-q - boot into bootloader if available"
  echo "-r - recovery from backup. If backup is on local machine it will push it to /sdcard/clockworkmod/backup/"
  echo "-s - wipe system when using -w.  USE ONLY IF YOU KNOW WHAT YOU ARE DOING"
  echo "-w - wipe Dalvik /cache /data it is optional [num] specifies how many wipes to do"
  echo "list in order the update.zip files you want to install"
  exit 1
fi

while getopts ":w:br:ld:qs" opt; do
  case $opt in
    b)
      BACKUP=1
      ;;
    d)
      DEVICE=$OPTARG
      ADB=$ADB" -s $OPTARG" 
      ;;
    w)
      if [ $OPTARG -eq $OPTARG 2> /dev/null ]; then
        WIPE=$OPTARG
      else
        echo "-w needs a number after it"
        exit 1
      fi
      ;;
    r)
      RECOVER=$OPTARG
      ;;
    l)
      LIST=1
      ;;
    q)
      BOOTLOADER=1
      ;;
    s)
      WIPE_SYSTEM=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ `ps -ef | grep -v "grep" | grep -c "adb fork-server"` -lt 1 ]; then
  echo "ADB server isn't running"
  exit 1
fi

NUM_DEVICES=`$ADB devices | wc -l `
if [ $NUM_DEVICES -lt 3 ]; then
  echo "Couldn't find device"
  exit 1
fi

if [ $NUM_DEVICES -gt 3 ] && [ $DEVICE == 0 ]; then
  echo -e "\n$BOLD$RED"
  echo -n "You will need to use the -d option with one of the following device IDs"
  echo -e "\n$NORM"
  $ADB devices 
  exit 1
fi

if [ $NUM_DEVICES -gt 3 ] && [ $DEVICE != 0 ]; then
  DEVICE_STATE=`adb devices | grep -v attached | grep $DEVICE | awk '{print $2}'`
else
  DEVICE_STATE=`adb devices | grep -v attached | awk '{print $2}'`
fi

if [ $DEVICE_STATE == "unknown" ]; then
  echo -e "\n$BOLD$RED"
  echo -n "Device is in an unknown state.  Are you sure you have the correct ID?"
  echo -e "\n$NORM"
  exit 1
fi

if [ -f $EXTCOMMANDS ]; then
  rm $EXTCOMMANDS
fi


echo "ui_print(\"_______  _______  _______  _______  _         \");" >> $EXTCOMMANDS
echo "ui_print(\"(  ____ \(  ____ )(  ___  )(  ____ \| \    /\ \");" >> $EXTCOMMANDS
echo "ui_print(\"| (    \/| (    )|| (   ) || (    \/|  \  / / \");" >> $EXTCOMMANDS
echo "ui_print(\"| |      | (____)|| (___) || |      |  (_/ /  \");" >> $EXTCOMMANDS
echo "ui_print(\"| |      |     __)|  ___  || |      |   _ (   \");" >> $EXTCOMMANDS
echo "ui_print(\"| |      | (\ (   | (   ) || |      |  ( \ \  \");" >> $EXTCOMMANDS
echo "ui_print(\"| (____/\| ) \ \__| )   ( || (____/\|  /  \ \ \");" >> $EXTCOMMANDS
echo "ui_print(\"(_______/|/   \__/|/     \|(_______/|_/    \/ \");" >> $EXTCOMMANDS
echo "ui_print(\"                                              \");" >> $EXTCOMMANDS
echo "ui_print(\"                CrackFlasher                  \");" >> $EXTCOMMANDS
echo "ui_print(\"  https://github.com/JimShoe/crackflasher     \");" >> $EXTCOMMANDS
echo "ui_print(\"_______  _        _______  _______            \");" >> $EXTCOMMANDS
echo "ui_print(\"(  ____ \( \      (  ___  )(  ____ \|\     /| \");" >> $EXTCOMMANDS
echo "ui_print(\"| (    \/| (      | (   ) || (    \/| )   ( | \");" >> $EXTCOMMANDS
echo "ui_print(\"| (__    | |      | (___) || (_____ | (___) | \");" >> $EXTCOMMANDS
echo "ui_print(\"|  __)   | |      |  ___  |(_____  )|  ___  | \");" >> $EXTCOMMANDS
echo "ui_print(\"| (      | |      | (   ) |      ) || (   ) | \");" >> $EXTCOMMANDS
echo "ui_print(\"| )      | (____/\| )   ( |/\____) || )   ( | \");" >> $EXTCOMMANDS
echo "ui_print(\"|/       (_______/|/     \|\_______)|/     \| \");" >> $EXTCOMMANDS
echo "ui_print(\"                                              \");" >> $EXTCOMMANDS
echo "ui_print(\"                                              \");" >> $EXTCOMMANDS

if [ $BACKUP -eq 1 ]; then
  backup_file=`date +%Y-%m-%d.%H.%M.%S`
  echo "backup_rom(\"/sdcard/clockworkmod/backup/$backup_file\");" >> $EXTCOMMANDS
  echo -e "${BOLD}${GREEN}BACKUP${NORM} /sdcard/clockworkmod/backup/$backup_file";
fi

for ((i=0; i < $WIPE; i++)) {
  echo "format(\"/cache\");" >> $EXTCOMMANDS
  echo "format(\"/data\");" >> $EXTCOMMANDS
  echo "format(\"/sd-ext\");" >> $EXTCOMMANDS
  echo "format(\"/sdcard/.android_secure\");" >> $EXTCOMMANDS
  if [ $WIPE_SYSTEM -eq 1 ]; then
    echo "format(\"/system\");" >> $EXTCOMMANDS
    echo -e "${BOLD}${RED}FORMATTING${NORM} Dalvik, /cache, /data, /sd-ext"
    echo -e "${BOLD}${RED}FORMATTING SYSTE!!!${NORM}"
  else
    echo -e "${BOLD}${RED}FORMAT${NORM} Dalvik, /cache, /data, /sd-ext"
  fi
}


if [ $RECOVER != 0 ]; then
    if [ $(echo "$RECOVER" | grep -c "^/sdcard") != 0 ]; then
      echo -e "${BOLD}${GREEN}RESTORE${NORM} - $RECOVER"
      echo "restore_rom(\"$RECOVER\");" >> $EXTCOMMANDS
    else
      filename=`basename $RECOVER`
      if [ `$ADB shell stat /sdcard/clockworkmod/backup/$filename | grep -c "can't stat"` -eq 0 ]; then
        echo "Pushing $filename to sdcard" 
        read -n1 -p "$filename already exists on sdcard, overwrite? (y/N) [N] "
        if [[ $REPLY = [yY] ]]; then
          echo
          $ADB shell rm -r /sdcard/clockworkmod/backup/$filename
          $ADB shell mkdir /sdcard/clockworkmod/backup/$filename
          $ADB push $RECOVER /sdcard/clockworkmod/backup/$filename 2> /dev/null
        fi
      fi
      echo "restore_rom(\"/sdcard/clockworkmod/backup/$filename\");" >> $EXTCOMMANDS
      echo -e "${BOLD}${GREEN}RESTORE${NORM} - $RECOVER"
    fi
else
  args=("$@")
  for ((i=$OPTIND-1; i < $#; i++)) {
    fullpath=${args[$i]}
    filename=`basename ${args[$i]}`
    if [ `$ADB shell stat /sdcard/$filename | grep -c "can't stat"` -eq 0 ]; then
      echo "Pushing $filename to /sdcard"
      read -n1 -p "$filename already exists on sdcard, overwrite? (y/N) [N] "
      if [[ $REPLY = [yY] ]]; then
        echo
        $ADB shell rm -r /sdcard/$filename
        $ADB push $fullpath /sdcard/ 2> /dev/null
      fi
    else
        echo "Pushing $filename to /sdcard"
        $ADB push $fullpath /sdcard/ 2> /dev/null
    fi
    echo
    echo "install_zip(\"/sdcard/$filename\");" >> $EXTCOMMANDS
    echo -e "${BOLD}${GREEN}Install${NORM} /sdcard/$filename"
  }
fi

if [ $LIST -eq 1 ]; then
  echo "List of backups on sdcard"
  echo ""
  $ADB shell find /sdcard/clockworkmod/backup -type d | grep "/sdcard/clockworkmod/backup/"
  exit
fi

if [ $BOOTLOADER -eq 1 ]; then
  echo -e "${BOLD}${RED}REBOOT BOOTLOADER${NORM} Going to reboot into bootloader when complete"
  echo "run_program(\"/sbin/reboot\",\"bootloader\");" >> $EXTCOMMANDS
fi

echo -e "\n$BOLD$RED"
read -n1 -p "REBOOT & INSTALL? (y/N) [N] "
echo -e "\n$NORM"
echo
if [[ $REPLY = [yY] ]]; then
  if [ `$ADB root | grep -c "already running as root"` -ne 1 ]; then
    sleep 5
  fi
  $ADB push $EXTCOMMANDS /cache/recovery/ 2> /dev/null
  $ADB reboot recovery
else
  echo "Aborting!."
  exit 1;
fi

