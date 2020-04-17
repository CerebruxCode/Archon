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

########Filesystem Function##################
function filesystems() {
	PS3="Επιλέξτε filesystem: "
	options=("ext4" "XFS" "Btrfs" "F2FS")
	select opt in "${options[@]}"
	do
		case $opt in
			"ext4")
				fsprogs="e2fsprogs"
				mkfs.ext4 "$diskvar""$disknumber"
				if [[ "$disknumber" == "1" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == "2" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
			"XFS")
			  fsprogs="xfsprogs"
				mkfs.xfs "$diskvar""$disknumber"
				if [[ "$disknumber" == "1" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == "2" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
			"Btrfs")
				fsprogs="btrfs-progs"
				mkfs.btrfs "-f" "$diskvar""$disknumber"
				if [[ "$disknumber" == "1" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == "2" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
				"F2FS")
					fsprogs="f2fs-tools"
					mkfs.f2fs "-f" "$diskvar""$disknumber"
					if [[ "$disknumber" == "1" ]]; then
							mount "$diskvar""$disknumber" "/mnt"
					elif [[ "$disknumber" == "2" ]]; then
							mount "$diskvar""$disknumber" "/mnt"
					fi
					break
					;;
				*) echo "Invalid option $Reply";;
			esac
		done
}
########Filesystem End ######################
function chroot_stage {
	echo
	echo '---------------------------------------------'
	echo '7 - Τροποποίηση Γλώσσας και Ζώνης Ώρας       '
	echo '                                             '
	echo 'Θα ρυθμίσουμε το σύστημα να είναι στα Αγγλικά'
	echo 'και ζώνη ώρας την Ελλάδα/Αθήνα               '
	echo '---------------------------------------------'
	echo
	sleep 2
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
	echo LANG=en_US.UTF-8 > /etc/locale.conf
	export LANG=en_US.UTF-8
	ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
	hwclock --systohc
	echo
	echo
	echo '---------------------------------------------'
	echo '8 - Ρύθμιση Hostname                         '
	echo '                                             '
	echo 'Θα χρειαστεί να δώσετε ένα όνομα στον        '
	echo 'Υπολογιστή σας                               '
	echo '---------------------------------------------'
	sleep 2
	echo
	read -rp "Δώστε όνομα υπολογιστή (hostname): " hostvar
	echo "$hostvar" > /etc/hostname
	echo
	sleep 2
	echo '-------------------------------------'
	echo '9 - Ρύθμιση της κάρτας δικτύου       '
	echo '                                     '
	echo 'Θα ρυθμιστεί η κάρτα δικτύου σας ώστε'
	echo 'να ξεκινάει αυτόματα με την εκκίνηση '
	echo 'του Arch Linux                       '
	echo '-------------------------------------'
	sleep 2
	ethernet=$(ip link | grep "2: "| grep -oE "(en\\w+)")		# Αναζήτηση κάρτας ethernet
	if [ "$ethernet" = "" ]; then					  			# Έλεγχος αν υπάρχει κάρτα ethernet
		echo "Δε βρέθηκε κάρτα δικτύου"							# και αν υπάρχει γίνεται εγκατάσταση
	else 								  						# και ενεργοποίηση
		   systemctl enable dhcpcd@"$ethernet".service
		echo "Η κάρτα δικτύου $ethernet ρυθμίστηκε επιτυχώς";
	fi
	echo
	wifi=$(ip link | grep ": "| grep -oE "(w\\w+)")				# Αναζήτηση κάρτας wifi
	if [ "$wifi" = "" ]; then									# Έλεγχος αν υπάρχει κάρτα wifi
		echo "Δε βρέθηκε ασύρματη κάρτα δικτύου"				# και αν υπάρχει γίνεται εγκατάσταση
	else 								  						# και ενεργοποίηση
		pacman -S --noconfirm iw wpa_supplicant dialog wpa_actiond
		systemctl enable netctl-auto@"$wifi".service
		echo "Η ασύρματη κάρτα δικτύου $wifi ρυθμίστηκε επιτυχώς"
	fi
	sleep 2
	echo
	echo '-------------------------------------'
	echo '10 - Ρύθμιση χρήστη ROOT             '
	echo '                                     '
	echo 'Αλλαγή συνθηματικού(password)        '
	echo 'του root χρήστη                      '
	echo '-------------------------------------'
	echo
	sleep 1
	#########################################################
	until passwd											# Μέχρι να είναι επιτυχής
	do														# η αλλαγή του κωδικού
	echo													# του root χρήστη, θα
	echo "O root κωδικός δεν άλλαξε, δοκιμάστε ξανά!"		# τυπώνεται αυτό το μήνυμα
	echo													#
	done													#
	#########################################################
	sleep 2
	echo
	echo
	echo '---------------------------------------'
	echo '11 - Linux LTS kernel (προαιρετικό)    '
	echo '                                       '
	echo 'Μήπως προτιμάτε τον LTS πυρήνα Linux  '
	echo 'ο οποίος είναι πιο σταθερός και μακράς '
	echo 'υποστήριξης;                           '
	echo '---------------------------------------'
	sleep 2
	if YN_Q "Θέλετε να εγκαταστήσετε πυρήνα μακράς υποστήριξης (Long Term Support) (y/n); "; then
		sudo pacman -S --noconfirm linux-lts
	fi
	echo
	echo
	echo '---------------------------------------'
	echo '12 - Ρύθμιση GRUB                      '
	echo '                                       '
	echo 'Θα γίνει εγκατάσταση του μενού επιλογών'
	echo 'εκκινησης GRUB Bootloader              '
	echo '---------------------------------------'
	echo
	sleep 2
	if [ -d /sys/firmware/efi ]; then
		pacman -S --noconfirm grub efibootmgr os-prober
		grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck
		grub-mkconfig -o /boot/grub/grub.cfg
	else
		pacman -S --noconfirm grub os-prober
		read -rp " Σε ποιο δίσκο θέλετε να εγκατασταθεί ο grub (/dev/sd?); " grubvar
		grub-install --target=i386-pc --recheck "$grubvar"
		grub-mkconfig -o /boot/grub/grub.cfg
	fi
	sleep 2
	echo
	echo '-------------------------------------'
	echo '13 - Δημιουργία Χρήστη               '
	echo '                                     '
	echo 'Για την δημιουργία νέου χρήστη θα    '
	echo 'χρειαστεί να δώσετε όνομα/συνθηματικό'
	echo '                                     '
	echo 'Στο χρήστη αυτόν θα δωθούν δικαιώματα'
	echo 'διαχειριστή (sudo)                   '
	echo '-------------------------------------'
	echo
	sleep 2
	read -rp "Δώστε παρακαλώ νέο όνομα χρήστη: " onomaxristi
	useradd -m -G wheel -s /bin/bash "$onomaxristi"
	#########################################################
	until passwd "$onomaxristi"				# Μέχρι να είναι επιτυχής
	do							# η αλλαγή του κωδικού
	echo							# του χρήστη, θα
	echo "O κωδικός του χρήστη δεν άλλαξε, δοκιμάστε ξανά!"	# τυπώνεται αυτό το μήνυμα
	echo							#
	done							#
	#########################################################
	echo "$onomaxristi ALL=(ALL) ALL" >> /etc/sudoers
	echo
	echo
	echo '-------------------------------------'
	echo '14 - Προσθήκη Multilib       '
	echo '                                     '
	echo 'Θα προστεθεί δυνατότητα για πρόσβαση '
	echo 'σε 32bit προγράμματα και βιβλιοθήκες '
	echo 'που απαιτούν κάποιες εφαρμογές       '
	echo '-------------------------------------'
	sleep 2
	echo
	{
		echo "[multilib]"
		echo "Include = /etc/pacman.d/mirrorlist"
	} >> /etc/pacman.conf
	pacman -Syy
	echo '--------------------------------------'
	echo '15 - Προσθήκη SWAP                    '
	echo '                                      '
	echo 'Θα χρησιμοποιηθεί το systemd-swap αντί'
	echo 'για διαμέρισμα SWAP ώστε το μέγεθός   '
	echo 'του να μεγαλώνει εάν και εφόσoν το    '
	echo 'απαιτεί το σύστημα                    '
	echo '--------------------------------------'
	sleep 2
	############################ Installing Zswap ###############################
	pacman -S --noconfirm systemd-swap
	# τα default του developer αλλάζουμε μόνο:
	echo
	{
			echo "zswap_enabled=0"
			echo "swapfc_enabled=1"
	} >> /etc/systemd/swap.conf.d/systemd-swap.conf
	systemctl enable systemd-swap
}

function YN_Q {
	while true; do
		read -rp "$1" yes_no
		case "$yes_no" in
			y|yes|Y|Yes|YES )
				return 0;
				break;;
			n|no|N|No|NO )
				return 1;
				break;;
			* )
				echo "${2:-"μη έγκυρη απάντηση"}";;
		esac
	done
}

clear


#Έλεγχος chroot
while test $# -gt 0; do
	case "$1" in
		--stage)
			shift
			if [ "$1" == "chroot" ]; then
				chroot_stage
				exit
			fi
			shift
			;;
		*)
			shift
			;;
	esac
done


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
if YN_Q "Θέλετε να συνεχίσετε (y/n); " "μη έγκυρος χαρακτήρας" ; then
	echo "Έναρξη της εγκατάστασης"
else
	echo " Έξοδος..."
	exit 0
fi
echo
sleep 1
echo '---------------------------------------'
echo ' 1 - Έλεγχος σύνδεσης στο διαδίκτυο    '
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
echo '                                              '
echo ' Διαλέξτε το δίσκο που θα γίνει η εγκατάσταση '
echo '----------------------------------------------'
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
	disknumber="2"
	filesystems
	mkdir "/mnt/boot"
	mount "$diskvar""1" "/mnt/boot"
else
	echo
	echo " Χρησιμοποιείς PC με BIOS";
	echo
	sleep 1
					########## Υποστηριξη GPT για BIOS συστήματα ##########
	echo "Θα θέλατε GPT Partition scheme ή MBR"
	echo
	PS3="Επιλογή partition scheme: "
	options=("MBR" "GPT")
	select opt in "${options[@]}"
	do
		case $opt in
			"MBR")
				disknumber="1"
				parted "$diskvar" mklabel msdos
				parted "$diskvar" mkpart primary ext4 1MiB 100%
				filesystems
				break
				;;
			"GPT")
				disknumber="2"
				parted "$diskvar" mklabel gpt
				parted "$diskvar" mkpart primary 1 3
				parted "$diskvar" set 1 bios_grub on
				parted "$diskvar" mkpart primary ext4 3MiB 100%
				filesystems
				break
				;;
			*) echo "invalid option $Reply";;
		esac
	done
fi
sleep 1
echo
echo
echo '--------------------------------------------------------'
echo ' 4 - Ανανέωση πηγών λογισμικού (Mirrors)                '
echo '--------------------------------------------------------'
#sleep 1
pacman -Syy
#pacman -S --noconfirm reflector #απενεργοποίηση λόγω bug του Reflector
#reflector --latest 10 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
#pacman -Syy
sleep 1
echo
echo
echo '--------------------------------------------------------'
echo ' 5 - Εγκατάσταση της Βάσης του Arch Linux               '
echo '                                                        '
echo ' Αν δεν έχετε κάνει ακόμα καφέ τώρα είναι η ευκαιρία... '
echo '--------------------------------------------------------'
sleep 1
pacstrap /mnt base base-devel linux linux-firmware dhcpcd "$fsprogs"
echo
echo
echo '--------------------------------------------------------'
echo ' 6 - Ολοκληρώθηκε η βασική εγκατάσταση του Arch Linux   '
echo '                                                        '
echo ' Τώρα θα γίνει είσοδος στο εγκατεστημένο Arch Linux     '
echo '--------------------------------------------------------'
sleep 1
cp archon.sh /mnt/archon.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./archon.sh --stage chroot
echo
echo
echo '--------------------------------------------------------'
echo ' Τέλος εγκατάστασης                                     '
echo ' Το σύστημα θα επανεκκινήσει σε 5 δευτερόλεπτα          '
echo '--------------------------------------------------------'
sleep 5
reboot
