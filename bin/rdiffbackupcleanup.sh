#!/bin/bash
rdiff-backup --remove-older-than 15B /mnt/HDD1/backup/daily
rdiff-backup --remove-older-than 10B /mnt/HDD1/backup/weekly
