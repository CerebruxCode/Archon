#!/bin/bash
#
#
# Archon -- Ελληνικός Arch Linux Installer
# Copyright (c)2017 Vasilis Niakas, Salih Emin and Contributors
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 3 of the License.
#
# Please read the file LICENSE, README and AUTHORS for more information.
#
#
clear

#Τυπικός έλεγχος για το αν είσαι root. because you never know
if [ "$(id -u)" -ne 0 ] ; then 
        echo "Λυπάμαι, αλλά πρέπει να είσαι root χρήστης για να τρέξεις το Archon."
        echo "Έξοδος..."
        sleep 2
        exit 1
fi
#Τυπικός έλεγχος για το αν το τρέχει σε Arch.
if [ ! -f /etc/arch-release ] ; then
    echo "Λυπάμαι, αλλά το σύστημα στο οποίο τρέχεις το Archon δεν είναι Arch Linux"
    echo "Έξοδος..."
        sleep 2
    exit
fi


setfont gr928a-8x16.psfu
echo '---------------------- Archon --------------------------'
echo "     _____                                              ";
echo "  __|_    |__  _____   ______  __   _  _____  ____   _  ";
echo " |    \      ||     | |   ___||  |_| |/     \|    \ | | ";
echo " |     \     ||     \ |   |__ |   _  ||     ||     \| | ";
echo " |__|\__\  __||__|\__\|______||__| |_|\_____/|__/\____| ";
echo "    |_____|                                             ";
echo "                                                        ";
echo "         Ο πρώτος Ελληνικός Arch Linux Installer        ";
echo '--------------------------------------------------------'
sleep 1
echo ' Σκοπός αυτού του cli εγκαταστάτη είναι η εγκατάσταση του'
echo ' βασικού συστήματος Arch Linux ΧΩΡΙΣ γραφικό περιβάλλον.'
echo ''
echo ' Η διαδικασία ολοκληρώνεται σε 15 βήματα'
echo ''
echo ' Προτείνεται η εγκατάσταση σε ξεχωριστό δίσκο για την '
echo ' αποφυγή σπασίματος του συστήματος σας. '
echo ''
echo ' Το script αυτό παρέχεται χωρίς καμιάς μορφής εγγύηση'
echo ' σωστής λειτουργίας.'
echo ''
echo ' You have been warned !!!'
sleep 5
echo
read -rp " Θέλετε να συνεχίσετε (y/n); " choice
case "$choice" in 
  y|Y ) sleep 1 && echo " Έναρξη της εγκατάστασης";;
  n|N ) sleep 1 && echo " Έξοδος..." && exit 0;;
  * ) echo "μη έγκυρος χαρακτήρας" && exit 0;;
esac
echo
sleep 1
echo '---------------------------------------'
echo ' 1 - Έλεγχος σύνδεσης στο διαδίκτυο'
echo '---------------------------------------'
if ping -c 3 www.google.com &> /dev/null; then
  echo '---------------------------------------'
  echo ' Υπάρχει σύνδεση στο διαδίκτυο'
  echo ' Η εγκατάσταση μπορεί να συνεχιστεί'
  echo '---------------------------------------'
else
  echo 'Ελέξτε αν υπάρχει σύνδεση στο διαδίκτυο'
  exit	
fi
sleep 1
echo
echo
echo '---------------------------------------------'
echo ' 2 - Παρακάτω βλέπετε τους διαθέσιμους δίσκους'
echo '                                             '
echo ' Διαλέξτε το δίσκο που θα γίνει η εγκατάσταση'
echo '---------------------------------------------'
lsblk | grep -i sd
echo
echo
echo '--------------------------------------------------------'
read -rp " Σε ποιο δίσκο (/dev/sd?) θα εγκατασταθεί το Arch; " diskvar
echo '--------------------------------------------------------'
echo
echo
echo '--------------------------------------------------------'
echo " Η εγκατάσταση θα γίνει στον $diskvar"
echo '--------------------------------------------------------'
sleep 1
echo
echo
echo '---------------------------------------------'
echo ' 3 - Γίνεται έλεγχος αν το σύστημά σας είναι '
echo '                                             '
echo '              BIOS ή UEFI                    '
echo '---------------------------------------------'
sleep 1
set -e
################### Check if BIOS or UEFI #####################
if [ -d /sys/firmware/efi ]; then
	echo
	echo " Χρησιμοποιείς PC με UEFI";
	echo
	sleep 1
	parted "$diskvar" mklabel gpt
	parted "$diskvar" mkpart ESP fat32 1MiB 513MiB
	parted "$diskvar" mkpart primary ext4 513MiB 100%
	mkfs.fat -F32 "$diskvar""1"
	mkfs.ext4 "$diskvar""2"
	mount "$diskvar""2" "/mnt"
	mkdir "/mnt/boot"
	mount "$diskvar""1" "/mnt/boot"
else
	echo	
	echo " Χρησιμοποιείς PC με BIOS";
	echo
	sleep 1
	parted "$diskvar" mklabel msdos
	parted "$diskvar" mkpart primary ext4 1MiB 100%
	mkfs.ext4 "$diskvar""1"
	mount "$diskvar""1" "/mnt"
fi
sleep 1
echo
echo 
echo '--------------------------------------------------------'
echo ' 4 - Προσθήκη πηγών λογισμικού (Mirrors)'
echo '--------------------------------------------------------'
sleep 1 
pacman -Syy
pacman -S --noconfirm reflector
reflector --latest 10 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy
sleep 1
echo
echo 
echo '--------------------------------------------------------'
echo ' 5 - Εγκατάσταση της Βάσης του Arch Linux               '
echo '                                                        '
echo ' Αν δεν έχετε κάνει ακόμα καφέ τώρα είναι η ευκαιρία... '
echo '--------------------------------------------------------'
sleep 1
pacstrap /mnt base base-devel
echo
echo 
echo '--------------------------------------------------------'
echo ' 6 - Ολοκληρώθηκε η βασική εγκατάσταση του Arch Linux   '
echo '                                                        '
echo ' Τώρα θα γίνει είσοδος στο εγκατεστημένο Arch Linux     '
echo '--------------------------------------------------------'
sleep 1
chmod +x archon.2
cp archon.2 /mnt/archon2.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./archon2.sh
echo
echo
echo '--------------------------------------------------------'
echo ' Τέλος εγκατάστασης'
echo ' Το σύστημα θα επανεκκινήσει σε 5 δευτερόλεπτα '
echo '--------------------------------------------------------'
sleep 5
reboot
