README for crackflasher
=============

Summary
-------------
Crackflasher is a bash script for flashing roms to android devies running ClockworkMod.

My Working Environment
-------------
### Local Machine
* Debian Testing
* HTC Thunderbolt
* ClockworkMod 3.1.0.2
* Android Debug Bridge version 1.0.26

Usage
-------------
You will need to set your ADB location in the script.

Usage: ./crackflasher.bash -b -w [num] update.zip update2.zip
-w - wipe Dalvik /cache /data it is optional [num] specifies how many wipes to do
-b - makes backup in /sdcard/clockworkmod/backup/ named date and is optional
-l - list backups in /sdcard/clockworkmod/backup/
-r - recovery from backup. If backup is on local machine it will push it to /sdcard/clockworkmod/backup/
list in order the update.zip files you want to instal

How it works
-------------
backup   - run "./crackflasher.bash -b"
           back will be in /sdcard/clockworkmod/backup/ named localmachine date and time.

restore  - run "./crackflasher.bash -r location"
           if location is on your localmachine it will push the dir to your sdcard
           if location is in /sdcard it will just use that locaiton

wipe     - run "./crackflasher.bash -w 2"
           this will wipe Dalvik /cache /data /sd-ext /sdcard/.android_secure twice

install  - run "./crackflasher.bash update.zip update2.zip"
           this will push each update.zip to /sdcard 
           this will install updates in the order they aprear in the command.

example  - ./crackflasher.bash -b -w 3 cm7.zip gapps.zip new_kernel.zip
           This will backup, wipe 3 times install cm7 gapps and new kernal in that order
