#!/bin/bash

###########################################################################
#                 CONFIG
# Location of adb
ADB="/home/nwarner/Desktop/android-sdk-linux_x86/platform-tools/adb"
###########################################################################

# flags
BACKUP=0
WIPE=0
RECOVER=0
LIST=0

EXTCOMMANDS="/tmp/extendedcommand"
BOLD="\033[1m"
NORM="\033[0m"
RED="\033[31m"
GREEN="\033[32m"

if [ $# -eq 0 ]; then
  echo "Usage: ./crack_flasher -b -w [num] update.zip update2.zip"
  echo "-w - wipe Dalvik /cache /data it is optional [num] specifies how many wipes to do"
  echo "-b - makes backup in /sdcard/clockworkmod/backup/ named date and is optional"
  echo "-l - list backups in /sdcard/clockworkmod/backup/"
  echo "-r - recovery from backup. If backup is on local machine it will push it to /sdcard/clockworkmod/backup/"
  echo "list in order the update.zip files you want to install"
  exit
fi

if [ `ps -ef | grep -v "grep" | grep -c "adb"` -lt 1 ]; then
  echo "plese run adb"
  exit
else
  if [ `$ADB devices | wc -l ` -lt 3 ]; then
    echo "Couldn't find device"
    exit
  fi
  rm $EXTCOMMANDS
fi

while getopts ":w:br:l" opt; do
  case $opt in
    b)
      BACKUP=1
      ;;
    w)
      if [ $OPTARG -eq $OPTARG 2> /dev/null ]; then
        WIPE=$OPTARG
      else
        echo "-w needs a number after it"
        exit
      fi
      ;;
    r)
      RECOVER=$OPTARG
      ;;
    l)
      LIST=1
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


if [ $BACKUP -eq 1 ]; then
  backup_file=`date +%Y-%m-%d.%H.%M.%S`
  echo "backup_rom(\"/sdcard/clockworkmod/backup/$backup_file\");" >> $EXTCOMMANDS
  echo -e "${BOLD}${GREEN}BACKUP${NORM} /sdcard/clockworkmod/backup/$backup_file";
fi

for ((i=0; i < $WIPE; i++)) {
  echo "run_program(\"/cache/dowipedalvikcache.sh\");" >> $EXTCOMMANDS
  echo "format(\"/cache\");" >> $EXTCOMMANDS
  echo "format(\"/data\");" >> $EXTCOMMANDS
  echo "format(\"/sd-ext\");" >> $EXTCOMMANDS
  echo "format(\"/sdcard/.android_secure\");" >> $EXTCOMMANDS
  echo -e "${BOLD}${RED}FORMAT${NORM} Dalvik, /cache, /data, /sd-ext"
}


if [ $RECOVER != 0 ]; then
    if [ $(echo "$RECOVER" | grep -c "^/sdcard") != 0 ]; then
      echo "${BOLD}${GREEN}RESTORE${NORM} - $RECOVER"
      echo "restore_rom(\"$RECOVER\");" >> $EXTCOMMANDS
    else
      filename=`basename $RECOVER`
      if [ `$ADB shell stat /sdcard/clockworkmod/backup/$filename | grep -c "can't stat"` -eq 0 ]; then
        read -n1 -p "Backup already exists on sdcard, overwrite? (y/N) [N] "
        if [[ $REPLY = [yY] ]]; then
          echo
          echo "Pushing $filename to sdcard" 
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
    echo "install_zip(\"/sdcard/$filename\");" >> $EXTCOMMANDS
    echo "Pushing $filename to /sdcard"
    $ADB push $fullpath /sdcard/ 2> /dev/null
    echo "Going to be installing /sdcard/$filename"
  }
fi

if [ $LIST -eq 1 ]; then
  echo "List of backups on sdcard"
  echo ""
  $ADB shell find /sdcard/clockworkmod/backup -type d | grep "/sdcard/clockworkmod/backup/"
  exit
fi


$ADB push $EXTCOMMANDS /cache/recovery/ 2> /dev/null

echo -e "\n$BOLD$RED"
read -n1 -p "REBOOT & INSTALL? (y/N) [N] "
echo
[[ $REPLY = [yY] ]] && $ADB reboot recovery || { echo "Aborting!."; exit 1; }

