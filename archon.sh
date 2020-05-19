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


# A few colors
#
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
#IBlue='\033[0;94m'        # Blue
#IPurple='\033[0;95m'      # Not used yet Purple
#ICyan='\033[0;96m'        # Not used yet Cyan
#IWhite='\033[0;97m'       # White
NC='\033[0m'


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
			*) echo -e "${IRed}Οι επιλογές σας πρέπει να είναι [1 ~ 4]. Παρακαλώ προσπαθήστε ξανα!${NC}"
			esac
		done
}
########Filesystem End ########################################
######## Functions for Desktop and X Dsiplay server (X-Org)####
#
function check_if_in_VM() {
    echo -e "${IGreen}Έλεγχος περιβάλλοντος (PC | VM) ...${NC}"
    sleep 2
    pacman -S --noconfirm facter
    if [[ $(facter 2>/dev/null | grep 'is_virtual' | awk -F'=> ' '{print $2}') == true ]]; then
        echo -e "${IGreen}Είμαστε σε VM (VirtualBox | VMware) ...${NC}"
		sleep 2
        pacman -S --noconfirm virtualbox-guest-dkms linux-headers xf86-video-vmware 
    else
        echo -e "${IGreen}Δεν είμαστε σε VM (VirtualBox | VMware) ...${NC}"
		sleep 2
        pacman -Rs --noconfirm facter
    fi
    sleep 2
}


function installer() {
    echo -e "${IGreen}Εγκατάσταση $1 ...${NC}"
    if pacman -S --noconfirm $2
    then
        echo -e "${IGreen}[ ΕΠΙΤΥΧΗΣ ] Εγκατάσταση $1 ...${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση $1 ...${NC}"
    fi
}

#  Check Net Connection | If it is off , exit immediately
#
function check_net_connection() {
    sleep 1
    echo '---------------------------------------'
    echo ' Έλεγχος σύνδεσης στο διαδίκτυο        '
    echo '---------------------------------------'
    if ping -c 3 www.google.com &> /dev/null; then
        echo -e "${IYellow} Η σύνδεση στο διαδίκτυο φαίνεται ενεργοποιημένη...Προχωράμε...\n${NC}"
    else
        echo -e "${IRed} Η σύνδεση στο Διαδίκτυο φαίνεται απενεργοποιημένη ... Ματαίωση ...\n"
        echo -e "Συνδεθείτε στο Διαδίκτυο και δοκιμάστε ξανά ... \n Ματαίωση...${NC}"
        exit 1
    fi
}

function initialize_desktop_selection() {
	sleep 2
    installer "Xorg Server" "xorg xorg-server xorg-xinit alsa-utils alsa-firmware pulseaudio noto-fonts"		# Εγκατάσταση Xorg Server
    PS3='Επιλέξτε ένα από τα διαθέσιμα γραφικά περιβάλλοντα : '

	options=("GNOME" "Mate" "Deepin" "Xfce" "KDE" "LXQt" "Cinnamon" "Budgie" "i3" "Enlightenment" "UKUI" "Fluxbox" "Sugar" "Twm" "Έξοδος")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")
                echo -e "Εγκατάσταση GNOME Desktop Environment ...\n"
                installer "GNOME Desktop" "gnome gnome-extra"
                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 		"Mate")
                echo -e "Εγκατάσταση Mate Desktop Environment ... \n"
                installer "Mate Desktop" "mate mate-extra networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Deepin")
                echo -e "Εγκατάσταση Deepin Desktop Environment ...\n"
                installer "Deepin Desktop" "deepin deepin-extra networkmanager"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Xfce")
                echo -e "Εγκατάσταση Xfce Desktop Environment ... \n"
                installer "Xfce Desktop" "xfce4 xfce4-goodies pavucontrol networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "KDE")
                echo -e "Εγκατάσταση KDE Desktop Environment ... \n"
                installer "KDE Desktop" "plasma-meta konsole dolphin"
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "LXQt")
                echo -e "Εγκατάσταση LXQt Desktop Environment ... \n"
                installer "LXQt Desktop" "lxqt breeze-icons"
                installer "SDDM Display Manager" "sddm"                
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Cinnamon")
                echo -e "Εγκατάσταση Cinnamon Desktop Environment ... \n"
                installer "Cinnamon Desktop" "cinnamon xterm networkmanager"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"                
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Budgie")
                echo -e "Εγκατάσταση Budgie Desktop Environment ... \n"
                installer "Budgie Desktop" "budgie-desktop budgie-extras xterm networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "i3")
                echo -e "Εγκατάσταση i3 Desktop Environment ... \n"
                installer "i3 Desktop" "i3 dmenu rxvt-unicode"
                echo -e '#!/bin/bash \nexec i3' > /home/$USER/.xinitrc
                exit 0
                ;;
        "Enlightenment")
                echo -e "Εγκατάσταση Enlightenment Desktop Environment ... \n"
                installer "Enlightenment Desktop" "enlightenment terminology connman"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable connman.service
                exit 0
                ;;
        "UKUI")
                echo -e "Εγκατάσταση UKUI Desktop Environment ... \n"
                installer "UKUI Desktop" "ukui xterm networkmanager network-manager-applet"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Fluxbox")
                echo -e "Εγκατάσταση Fluxbox Desktop Environment ... \n"
                installer "Fluxbox Desktop" "fluxbox xterm menumaker"
                echo -e '#!/bin/bash \nstartfluxbox' > /home/$USER/.xinitrc
                exit 0
                ;;
        "Sugar")
                echo -e "Εγκατάσταση Sugar Desktop Environment ... \n"
                installer "Sugar Desktop" "sugar sugar-fructose xterm"
                installer "LXDM Display Manager" "lxdm"
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Twm")
                echo -e "Εγκατάσταση Twm Desktop Environment ... \n"
                installer "Twm Desktop" "xorg-twm xterm xorg-xclock"
                exit 0
                ;;
		"Έξοδος")
                echo -e "Έξοδος όπως επιλέχθηκε από το χρήστη "${USER}""
                exit 0
                ;;
            *)
                echo -e "${IRed}Οι επιλογές σας πρέπει να είναι [1 ~ 14]. Παρακαλώ προσπαθήστε ξανα!${NC}"
                ;;
        esac
	done
}
######## END of Functions for Desktop and X Dsiplay server (X-Org)####

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
	if [ "$ethernet" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα ethernet
		echo "Δε βρέθηκε κάρτα δικτύου"				# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		   systemctl enable dhcpcd@"$ethernet".service
		echo "Η κάρτα δικτύου $ethernet ρυθμίστηκε επιτυχώς";
	fi
	echo
	wifi=$(ip link | grep ": "| grep -oE "(w\\w+)")			# Αναζήτηση κάρτας wifi
	if [ "$wifi" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα wifi
		echo "Δε βρέθηκε ασύρματη κάρτα δικτύου"		# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
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
	until passwd						# Μέχρι να είναι επιτυχής
	do							# η αλλαγή του κωδικού
	echo							# του root χρήστη, θα
	echo "O root κωδικός δεν άλλαξε, δοκιμάστε ξανά!"	# τυπώνεται αυτό το μήνυμα
	echo							#
	done							#
	#########################################################
	sleep 2
	echo
	echo
	echo '---------------------------------------'
	echo '11 - Linux LTS kernel (προαιρετικό)    '
	echo '                                       '
	echo 'Μήπως προτιμάτε τον LTS πυρήνα Linux   '
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
	pacman -S --noconfirm grub efibootmgr os-prober
	lsblk --noheadings --raw -o NAME,MOUNTPOINT | awk '$1~/[[:digit:]]/ && $2 == ""' | grep -oP sd\[a-z]\[1-9]+ | sed 's/^/\/dev\//' > disks.txt
	filesize=$(stat --printf="%s" disks.txt | tail -n1)
	
	cd run 
	mkdir media 
	cd media
	cd /
	if [ $filesize -ne 0 ]; then
		num=0
  		while IFS='' read -r line || [[ -n "$line" ]]; do
	        num=$(( $num + 1 ))
		    echo $num
		    mkdir /run/media/disk$num
		    mount $line /run/media/disk$num | echo "Προσαρτάται ο..."$num"oς δίσκος"
		    sleep 1
      
		  done < "disks.txt"

		else
		  echo "Δεν υπάρχουν άλλοι δίσκοι στο σύστημα"
	fi
	sleep 5
	rm disks.txt
	
	if [ -d /sys/firmware/efi ]; then
		#pacman -S --noconfirm grub efibootmgr os-prober
		grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck
		grub-mkconfig -o /boot/grub/grub.cfg
	else
		#pacman -S --noconfirm grub os-prober
		#lsblk | grep -i sd
		#read -rp " Σε ποιο δίσκο θέλετε να εγκατασταθεί ο grub (/dev/sd? | /dev/nvme?); " grubvar
		diskchooser grub
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
  	do							# η εντολή
	echo "O κωδικός του χρήστη δεν άλλαξε, δοκιμάστε ξανά!"	# τυπώνεται αυτό το μήνυμα
	echo							#
	done							#
	#########################################################
	echo "$onomaxristi ALL=(ALL) ALL" >> /etc/sudoers
	echo
	echo
	echo '-------------------------------------'
	echo '14 - Προσθήκη Multilib               '
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
	
	echo '--------------------------------------'
	echo 'BONUS - Εγκατάσταση Desktop           '
	echo '                                      '
	echo 'Θέλετε να εγκαταστήσετε κάποιο γραφικό'
	echo 'περιβάλλον  ;                         '
	echo '                                      '
	echo '         ΣΗΜΑΝΤΙΚΟ:                   '
	echo 'Τα διαθέσιμα γραφικά περιβάλλοντα     '
	echo 'είναι ΜΟΝΟ από τα επίσημα αποθετήρια  '
	echo 'και όχι από το AUR. Όποιο και αν      '
	echo 'διαλέξετε, θα εγκατασταθεί ΜΟΝΟ το    '
	echo 'γραφικό περιβάλλον με βάση τις        '
	echo 'επίσημες KISS οδηγίες του Arch Wiki   '
	echo '--------------------------------------'
	sleep 2
	############# Installing Desktop ###########
	if YN_Q "Θέλετε να συνεχίσετε (y/n); " "μη έγκυρος χαρακτήρας" ; then
		echo "Έναρξη της εγκατάστασης"
		check_net_connection
		check_if_in_VM
    	initialize_desktop_selection
	else
		echo " Έξοδος..."
		exit 0
	fi
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

#Συνάρτηση επιλογής δίσκου πιο failsafe για αποφυγή λάθους######
function diskchooser() {

lsblk --noheadings --raw | grep disk | awk '{print $1}' > disks

while true
do
echo "---------------------------------------------------------"
num=0 

while IFS='' read -r line || [[ -n "$line" ]]; do
    num=$(( $num + 1 ))
    echo "["$num"]" $line
done < disks
echo "---------------------------------------------------------"
read -rp "Επιλέξτε δίσκο για εγκατάσταση (Q/q για έξοδο): " input

if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   	then
	echo "Έξοδος..."
	tput cnorm   -- normal  	# Εμφάνιση cursor
	exit 0
fi

if [ $input -gt 0 -a $input -le $num ]; #έλεγχος αν το input είναι μέσα στο εύρος της λίστας
	then
	if [[ $1 = "grub" ]];		# αν προστεθεί το όρισμα grub τότε η μεταβλητή που θα αποθηκευτεί
	then				# θα είναι η grubvar
	grubvar="/dev/"$(cat disks | head -n$(( $input )) | tail -n1 )
	echo Διάλεξατε τον $grubvar
	else
	diskvar="/dev/"$(cat disks | head -n$(( $input )) | tail -n1 )
	echo Διάλεξατε τον $diskvar
	fi
	break
	else
	echo "Αριθμός εκτός λίστας"
	sleep 2
	clear
fi
done
rm disks

}
export -f diskchooser
################################################################

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
echo '----------------------------------------------'
echo ' 2 - Παρακάτω βλέπετε τους διαθέσιμους δίσκους'
echo '                                              '
echo ' Γράψτε την διαδρομή του δίσκου στον οποίο θα '
echo ' γίνει η εγκατάσταση του Arch Linux           '
echo '----------------------------------------------'

diskchooser
#lsblk | grep -i 'sd\|nvme' #Προσθήκη nvme ανάγνωσης στην εντολή lsblk
#echo
#echo
#echo '--------------------------------------------------------'
#read -rp " Γράψτε σε ποιο δίσκο (με την μορφή /dev/sdX ή /dev/nvmeX) θα εγκατασταθεί το Arch; " diskvar
#echo '--------------------------------------------------------'
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
UEFI () {
if  [ "$diskvar" = "/dev/sd*" ]; then
    parted "$diskvar" mklabel gpt
	parted "$diskvar" mkpart ESP fat32 1MiB 513MiB
	parted "$diskvar" mkpart primary ext4 513MiB 100%
	mkfs.fat -F32 "$diskvar""1"
	disknumber="2"
	filesystems
	mkdir "/mnt/boot"
	mount "$diskvar""1" "/mnt/boot"
	sleep 1
else
    parted "$diskvar" mklabel gpt
	parted "$diskvar" mkpart ESP fat32 1MiB 513MiB
	parted "$diskvar" mkpart primary ext4 513MiB 100%
    mkfs.fat -F32 "$diskvar""p1"
	mkfs.ext4 "$diskvar""p2"
	mount "$diskvar""p2" "/mnt"
	mkdir "/mnt/boot"
	mount "$diskvar""p1" "/mnt/boot"
	sleep 1
fi
}
BIOS () {
if [ "$diskvar" = "/dev/sd*" ]; then
    parted "$diskvar" mklabel msdos
	parted "$diskvar" mkpart primary ext4 1MiB 100%
    mkfs.ext4 "$diskvar""1"
	mount "$diskvar""1" "/mnt"
	sleep 1
else
    parted "$diskvar" mklabel msdos
	parted "$diskvar" mkpart primary ext4 1MiB 100%
    mkfs.ext4 "$diskvar""p1"
	mount "$diskvar""p1" "/mnt" 
	sleep1
fi
}
if [ -d /sys/firmware/efi ]; then  #Η αρχική συνθήκη παραμένει ίδια
	echo
	echo " Χρησιμοποιείς PC με UEFI";
	echo
	sleep 1
	UEFI   #Συνάρτηση για UEFI, αν προστεθεί sd? ή nvme? (line 311-333)
else
	echo
	echo " Χρησιμοποιείς PC με BIOS";
	echo
	sleep 1
  #Συνάρτηση για BIOS, αν προστεθεί sd? ή nvme? (line 334-348)
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
echo ' Μπορείτε να επανεκκινήσετε το σύστημά σας              '
echo '--------------------------------------------------------'
sleep 5
exit
