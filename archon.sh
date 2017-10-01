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
sleep 2
echo ' Σκοπός αυτού του cli εγκαταστάτη είναι η εγκατάσταση του'
echo ' βασικού συστήματος Arch Linux ΧΩΡΙΣ γραφικό περιβάλλον.'
echo ' Προτείνεται η εγκατάσταση σε ξεχωριστό δίσκο για την '
echo ' αποφυγή σπασίματος του συστήματος σας. Το script αυτό '
echo ' παρέχεται χωρίς καμιάς μορφής εγγύηση σωστής λειτουργίας.'
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
echo '---------------------------------------'
echo ' Έλεγχος σύνδεσης στο διαδίκτυο'
echo '---------------------------------------'
if ping -c 5 www.google.com &> /dev/null; then
  echo '---------------------------------------'
  echo ' Υπάρχει σύνδεση στο διαδίκτυο'
  echo ' Η εγκατάσταση μπορεί να συνεχιστεί'
  echo '---------------------------------------'
else
  echo 'Ελέξτε αν υπάρχει σύνδεση στο διαδίκτυο'
  exit	
fi
echo '---------------------------------------------'
echo ' Διαλέξτε το δίσκο που θα γίνει η εγκατάσταση'
echo '---------------------------------------------'
######################################## Advanced Installer #############################################
echo "Ο χώρος σε κάθε δίσκο είναι";
echo "---------------------------------------------";
echo "  Disk   Μέγεθος (Gigabytes)";
echo "---------------------------------------------";
lsblk -m | grep -i "sd[a-z][^0-9]" | awk '{print "  "$1"    "$2}' | awk 'gsub("G","")'
echo
while [ "$finished" != "true" ]
do
	read -rp "Σε ποιο δίσκο θέλεις να κάνεις την εγκατάσταση; " diskvar;
	if [ -z "$diskvar" ]; then
		echo "Δεν έχεις δώσει δίσκο"
	elif [[ $diskvar != *"/dev/sd"[a-z]* ]]; then									        # Έλεγχος αν το string
		echo "η απάντηση πρέπει να είναι της μορφης /dev/sdx" 								# περιέχει το /dev/sd
	elif [[ $(lsblk -m | grep -i "sd[a-z][^0-9]" | awk '{print $1}') == "" ]]; then		
		echo "μη έγκυρη ονομασία δίσκου"	
	else
      		finished=true	
	fi
done
disksize=$(lsblk "$diskvar" | grep "sd[a-z][^0-9]" | awk '{print $4}' | awk 'gsub("G","")' | awk '{print int($1+0.5)}' )  	# αποθηκεύει το μέγεθος υ																# δίσκου και αφαιρεί 
															  	# το "G" για να είναι 	
																# αριθμός η μεταβλητή		
echo "το μέγεθος του δίσκου είναι $disksize Gigabytes";
echo
numberpart=$(grep -c "${diskvar:(-3)}[0-9]" /proc/partitions)
if [ "$numberpart" == 1 ]; then
	echo "Στο δίσκο ${diskvar:(-3)} υπάρχει ήδη $numberpart κατάτμηση";
elif [ "$numberpart" == 0 ]; then
	echo "Στο δίσκο ${diskvar:(-3)} δεν υπάρχουν κατατμήσεις";
else
	echo "Στο δίσκο ${diskvar:(-3)} υπάρχουν ήδη $numberpart κατατμήσεις";
fi 
while [ "$finishpart" != "true" ]
do
	read -rp "Τι μέγεθος κατάτμηση θέλετε να κάνετε στο δισκο $diskvar; " disksizevar;
	if [ "$disksizevar" -ge "$disksize"  ] || [ -z "$disksizevar" ] || [ "$disksizevar" == 0 ] || [ $((disksizevar)) != "$disksizevar" ]; then
		echo "Το μέγεθος που δώσατε δε βρίσκεται εντός των ορίων του δίσκου"
	else
		echo "Η εγκατάσταση θα γίνει σε κατάτμηση μεγέθους $disksizevar Gigabytes";
		

		read -rp "Έιστε σίγουροι (y/n); " yn
		    if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
			finishpart=true
		    elif [ "$yn" == "n" ] || [ "$yn" == "N" ]; then
			finishpart=false
		    else
			echo "Μη έγκυρος χαρακτήρας"
		    fi

		
	fi
done
echo "Συνέχεια της εγκατάστασης..."
#sleep 1

#echo "Η νέα κατάτμηση θα είναι η ${diskvar:0:-1}$(( numberpart + 1 ))";
echo 
PS3='Μπορείτε να διαλέξετε ένα από τα παρακάτω σενάρια βάσει των οποίων θα εγκατασταθεί το Arch Linux: '
options=("Εγκατάσταση και δημιουργία swap κατάτμησης" "Εγκατάσταση χωρίς δημιουργία swap κατάτμησης" "Εγκατάσταση με δημιουργία home,swap κατατμήσεων")
select opt in "${options[@]}"
do
    case $opt in
        "Εγκατάσταση και δημιουργία swap κατάτμησης")
            echo "Η εγκατάσταση θα δημιουργήσει 2 κατατμήσεις, τη ${diskvar:0:-1}$(( numberpart + 1 )) και τη ${diskvar:0:-1}$(( numberpart + 2 ))";
	    read -rp "Έιστε σίγουροι (y/n); " yn
	    if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
		finishpart=false
		while [ "$finishpart" != "true" ]
		do
			read -rp "Τι μεγέθους κατάτμηση θέλετε για το swap [${diskvar:0:-1}$(( numberpart + 2 ))]; " swapvar;
			if [ "$swapvar" -ge "$disksizevar"  ] || [ -z "$swapvar" ] || [ "$swapvar" == 0 ] || [ $((swapvar)) != "$swapvar" ]; then
			echo "Το μέγεθος που δώσατε δε βρίσκεται εντός των ορίων του δίσκου"
				else
			echo "Το swap θα γίνει σε κατάτμηση μεγέθους $swapvar Gigabytes";
		

			read -rp "Έιστε σίγουροι (y/n); " yn
			    if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
				finishpart=true	
			    elif [ "$yn" == "n" ] || [ "$yn" == "N" ]; then
				echo "Παρακαλώ δώστε μέγεθος swap"
			    else
				echo "Μη έγκυρος χαρακτήρας"
			    fi
			fi		
		done
			if [ -d /sys/firmware/efi ]; then
				echo
				echo " Χρησιμοποιείς PC με UEFI";
	#			echo
	#			sleep 1
				parted "$diskvar" mklabel gpt
				parted "$diskvar" mkpart ESP fat32 1MiB 513MiB
				parted "$diskvar" mkpart primary ext4 513MiB 100%
				mkfs.fat -F32 "$diskvar""$numberpart"
				mkfs.ext4 "$diskvar""$(( numberpart + 1 ))"
				mount "$diskvar""$(( numberpart + 1 ))" /mnt"
				mkdir /mnt/boot
				mount ""$diskvar""$(( numberpart + 1 ))" /mnt/boot
				break
			else
				echo	
				echo " Χρησιμοποιείς PC με BIOS";
				echo
				sleep 1
				parted -s "$diskvar" mklabel msdos
				parted -s "$diskvar" mkpart primary ext4 1MiB "$(( disksizevar - swapvar ))"GiB
				parted -s "$diskvar" mkpart primary linux-swap "$(( disksizevar - swapvar ))"GiB 100%
				mkfs.ext4 "$diskvar""$(( numberpart + 1 ))"
				mkswap "$diskvar""$(( numberpart + 2 ))"
				swapon "$diskvar""$(( numberpart + 2 ))"
				mount "$diskvar""$(( numberpart + 1 ))" /mnt
				break
			fi
#		break
	    elif [ "$yn" == "n" ] || [ "$yn" == "N" ]; then
		clear
		echo "Επιλέξτε ξανά"
		echo "1) Εγκατάσταση και δημιουργία swap κατάτμησης";
		echo "2) Εγκατάσταση χωρίς δημιουργία swap κατάτμησης";
                echo "3) Εγκατάσταση με δημιουργία home,swap κατατμήσεων";
	    else
		echo "Μη έγκυρος χαρακτήρας"
	    fi;;
	    #break;;
        "Εγκατάσταση χωρίς δημιουργία swap κατάτμησης")
            echo "Η εγκατάσταση θα δημιουργήσει 1 κατάτμηση, τη ${diskvar:0:-1}$(( numberpart + 1 ))";
	    read -rp "Έιστε σίγουροι (y/n); " yn
	    if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
		if [ -d /sys/firmware/efi ]; then
			echo
			echo " Χρησιμοποιείς PC με UEFI";
#			echo
#			sleep 1
			parted "$diskvar" mklabel gpt
			parted "$diskvar" mkpart ESP fat32 1MiB 513MiB
			parted "$diskvar" mkpart primary ext4 513MiB 100%
			mkfs.fat -F32 "$diskvar""$numberpart"
			mkfs.ext4 "$diskvar""$(( numberpart + 1 ))"
			mount "$diskvar""$(( numberpart + 1 ))" /mnt"
			mkdir /mnt/boot
			mount ""$diskvar""$(( numberpart + 1 ))" /mnt/boot
			break
		else
			echo	
			echo " Χρησιμοποιείς PC με BIOS";
			echo
			sleep 1
			parted -s "$diskvar" mklabel msdos
			parted -s "$diskvar" mkpart primary ext4 1MiB 100%
			mkfs.ext4 "$diskvar""$(( numberpart + 1 ))"
			mount "$diskvar""$(( numberpart + 1 ))" /mnt
			break
		fi
	    elif [ "$yn" == "n" ] || [ "$yn" == "N" ]; then
		clear
		echo "Επιλέξτε ξανά"
		echo "1) Εγκατάσταση και δημιουργία swap κατάτμησης";
		echo "2) Εγκατάσταση χωρίς δημιουργία swap κατάτμησης";
                echo "3) Εγκατάσταση με δημιουργία home,swap κατατμήσεων";
	    else
		echo "Μη έγκυρος χαρακτήρας"
	    fi;;
	    #break;;
        "Εγκατάσταση με δημιουργία home,swap κατατμήσεων")
            echo "Η εγκατάσταση θα δημιουργήσει 3 κατατμήσεις, τη ${diskvar:0:-1}$(( numberpart + 1 )) τη ${diskvar:0:-1}$(( numberpart + 2 )) και τη ${diskvar:0:-1}$(( numberpart + 3 ))";

	    #break;;
	    read -rp "Έιστε σίγουροι (y/n); " yn
	    if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
		finishpart=false
		while [ "$finishpart" != "true" ]
		do
			read -rp "Τι μεγέθους κατάτμηση θέλετε για το swap [${diskvar:0:-1}$(( numberpart + 3 ))]; " swapvar;
			if [ "$swapvar" -ge "$disksizevar"  ] || [ -z "$swapvar" ] || [ "$swapvar" == 0 ] || [ $((swapvar)) != "$swapvar" ]; then
			echo "Το μέγεθος που δώσατε δε βρίσκεται εντός των ορίων του δίσκου"
				else
			echo "Το swap θα γίνει σε κατάτμηση μεγέθους $swapvar Gigabytes";
		

			read -rp "Έιστε σίγουροι (y/n); " yn
			    if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
				finishpart=true	
			    elif [ "$yn" == "n" ] || [ "$yn" == "N" ]; then
				echo "Παρακαλώ δώστε μέγεθος swap"
			    else
				echo "Μη έγκυρος χαρακτήρας"
			    fi
			fi		
		done
		finishpart=false
		while [ "$finishpart" != "true" ]
		do
			read -rp "Τι μεγέθους κατάτμηση θέλετε για το home [${diskvar:0:-1}$(( numberpart + 2 ))] (προτείνεται $((disksizevar - swapvar-10))); " homevar;
			if [ "$homevar" -ge "$((disksizevar - swapvar))"  ] || [ -z "$homevar" ] || [ "$homevar" == 0 ] || [ $((homevar)) != "$homevar" ]; then
			echo "Το μέγεθος που δώσατε δε βρίσκεται εντός των ορίων του δίσκου"
				else
			echo "Το home θα γίνει σε κατάτμηση μεγέθους $homevar Gigabytes ";
		

			read -rp "Έιστε σίγουροι (y/n); " yn
			    if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
				finishpart=true	
			    elif [ "$yn" == "n" ] || [ "$yn" == "N" ]; then
				echo "Παρακαλώ δώστε μέγεθος home"
			    else
				echo "Μη έγκυρος χαρακτήρας"
			    fi
			fi		
		done
		break
	    elif [ "$yn" == "n" ] || [ "$yn" == "N" ]; then
		clear
		echo "Επιλέξτε ξανά"
		echo "1) Εγκατάσταση και δημιουργία swap κατάτμησης";
		echo "2) Εγκατάσταση χωρίς δημιουργία swap κατάτμησης";
                echo "3) Εγκατάσταση με δημιουργία home,swap κατατμήσεων";

	    else
		echo "Μη έγκυρος χαρακτήρας"
	    fi;;

        
        *) echo "μη έγκυρη επιλογή";;
    esac
done
echo "Συνέχεια της εγκατάστασης..."
######################################## Advanced Installer - End #############################################
echo 
echo '--------------------------------------------------------'
echo ' Προσθήκη πηγών λογισμικού (Mirrors)'
echo '--------------------------------------------------------'
echo
sleep 1 
pacman -Syy
pacman -S --noconfirm --noprogressbar reflector
reflector --latest 10 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy
echo 
echo '--------------------------------------------------------'
echo ' Εγκατάσταση της Βάσης του Arch Linux'
echo ' Αν δεν έχετε κάνει ακόμα καφέ τώρα είναι η ευκαιρία... '
echo '--------------------------------------------------------'
echo
sleep 2
pacstrap /mnt base base-devel
echo 
echo '--------------------------------------------------------'
echo ' Είσοδος στο εγκατεστημένο Arch Linux'
echo '--------------------------------------------------------'
echo

chmod +x archon.2
cp archon.2 /mnt/archon2.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./archon2.sh
echo
echo '--------------------------------------------------------'
echo ' Τέλος εγκατάστασης'
echo ' Το σύστημα θα επανεκκινήσει σε 5 δευτερόλεπτα '
echo '--------------------------------------------------------'
sleep 5
reboot
