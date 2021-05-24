#!/bin/bash

rdiff-backup --exclude /var/cache --exclude /var/lock --exclude /var/run --exclude /var/spool --exclude /var/tmp --exclude /bin --exclude /boot --exclude /cdrom --exclude /dev --exclude /lib --exclude /lib32 --exclude /lib64 --exclude /libx32 --exclude /lost+found --exclude /media --exclude /mnt --exclude /proc --exclude /run --exclude /sbin --exclude /sys --exclude /tmp / /mnt/HDD1/backup/weekly
