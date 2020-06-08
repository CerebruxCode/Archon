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
function filesystems(){ 
	PS3="Επιλέξτε filesystem: "
    options=("ext4" "XFS (experimental)" "Btrfs" "F2FS (experimental)")
	select opt in "${options[@]}"
    do
		case $opt in # Η diskletter παίρνει τιμή μόνο αν είναι nvme ο δίσκος
			"ext4")
				fsprogs="e2fsprogs"
				mkfs.ext4 "$diskvar""$diskletter""$disknumber"
				mount "$diskvar""$diskletter""$disknumber" "/mnt"
				file_format="ext4"
				break
				;;
			"XFS (experimental)")
			    fsprogs="xfsprogs"
				mkfs.xfs "$diskvar""$diskletter""$disknumber"
				mount "$diskvar""$diskletter""$disknumber" "/mnt"
				file_format="xfs"
				break
				;;
            "Btrfs")
				fsprogs="btrfs-progs"
				mkfs.btrfs "-f" "$diskvar""$diskletter""$disknumber"
				mount "$diskvar""$diskletter""$disknumber" "/mnt"
				btrfs subvolume create /mnt/@
                echo
				if YN_Q "Θέλετε να προστεθεί subvolume home (y/n); " "μη έγκυρος χαρακτήρας" ; then
					btrfs subvolume create /mnt/@home
					umount /mnt
					mount -o subvol=/@ "$diskvar""$diskletter""$disknumber" /mnt
					mkdir -p /mnt/home
					mount -o subvol=/@home "$diskvar""$diskletter""$disknumber" /mnt/home
				else
					umount /mnt
					mount -o subvol=/@ "$diskvar""$diskletter""$disknumber" /mnt
				fi
				file_format="btrfs"
				break
				;;
			"F2FS (experimental)")
				fsprogs="f2fs-tools"
				mkfs.f2fs "-f" "$diskvar""$diskletter""$disknumber"
				mount "$diskvar""$diskletter""$disknumber" "/mnt"
				file_format="f2fs"
				break
				;;
			*) echo -e "${IRed}Οι επιλογές σας πρέπει να είναι [1 ~ 4]. Παρακαλώ επιλέξτε σωστά !${NC}";;
			esac
        done
    }


########Filesystem End ########################################
######## Functions for Desktop and X Dsiplay server (X-Org)####
#
function check_if_in_VM() {
    echo
    echo -e "${IGreen}Έλεγχος περιβάλλοντος (PC | VM) ...${NC}"
    sleep 2
	installer "Εγκατάσταση εργαλείου Ελέγχου : " facter
    if [[ $(facter 2>/dev/null | grep 'is_virtual' | awk -F'=> ' '{print $2}') == true ]]; then
        echo
        echo -e "${IGreen}Είμαστε σε VM (VirtualBox | VMware) ...${NC}"
		sleep 2
        installer "Πακέτα για VM" virtualbox-guest-dkms linux-headers xf86-video-vmware
    else
        echo
        echo -e "${IGreen}Δεν είμαστε σε VM (VirtualBox | VMware) αφαίρεση εργαλείων ελέγχου...${NC}"
		sleep 2
        pacman -Rs --noconfirm facter boost-libs cpp-hocon leatherman yaml-cpp
    fi
    sleep 2
}


function installer() {
    echo -e "${IGreen}Εγκατάσταση $1 ...${NC}"
    echo
	echo -e "${IYellow}Θα εγκατασταθούν τα : ${*:2} ${NC}" # Ενημέρωση του τι θα εγκατασταθεί
    echo
    if pacman -S --noconfirm "${@:2}" # Με ${*2} διαβάζει τα input
    then
        echo
        echo -e "${IGreen}[ ΕΠΙΤΥΧΗΣ ] Εγκατάσταση $1 ...${NC}"
    else
        echo
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση $1 ...${NC}"
    fi

}
#  Check Net Connection | If it is off , exit immediately
#
function check_net_connection() {
    sleep 1
    echo '----------------------------------------'
    echo -e "${IGreen}Έλεγχος σύνδεσης στο διαδίκτυο${NC}"
    echo '----------------------------------------'
    if ping -c 3 www.google.com &> /dev/null; then
        echo
        echo -e "${IYellow}Η σύνδεση στο διαδίκτυο φαίνεται ενεργοποιημένη...Προχωράμε...\n${NC}"
    else
        echo
        echo -e "${IRed} Η σύνδεση στο Διαδίκτυο φαίνεται απενεργοποιημένη ... Ματαίωση ...\n"
        echo -e "Συνδεθείτε στο Διαδίκτυο και δοκιμάστε ξανά ... \n Ματαίωση...${NC}"
        echo
        exit 1
    fi
}

function initialize_desktop_selection() {
	sleep 2
    echo
    echo "Εγκατάσταση Xorg Server"
    echo
    installer "Xorg Server" xorg xorg-server xorg-xinit alsa-utils alsa-firmware pulseaudio pulseaudio-alsa noto-fonts	# Εγκατάσταση Xorg Server και Audio server
    echo
    PS3='Επιλέξτε ένα από τα διαθέσιμα γραφικά περιβάλλοντα : '

	options=("GNOME" "Mate" "Deepin" "Xfce" "KDE" "LXQt" "Cinnamon" "Budgie" "i3" "Enlightenment" "UKUI" "Fluxbox" "Sugar" "Twm" "Έξοδος")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")
                echo -e "${IGreen}Εγκατάσταση GNOME Desktop Environment ...\n${NC}"
                installer "GNOME Desktop" gnome gnome-extra
                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 		"Mate")
                echo -e "${IGreen}Εγκατάσταση Mate Desktop Environment ... \n${NC}" 
                installer "Mate Desktop" mate mate-extra networkmanager network-manager-applet
                installer "LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Deepin")
                echo -e "${IGreen}Εγκατάσταση Deepin Desktop Environment ...\n${NC}"
                installer "Deepin Desktop" deepin deepin-extra networkmanager
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Xfce")
                echo -e "${IGreen}Εγκατάσταση Xfce Desktop Environment ... \n${NC}"
                installer "Xfce Desktop" xfce4 xfce4-goodies pavucontrol networkmanager network-manager-applet
                installer "LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "KDE")
                echo -e "${IGreen}Εγκατάσταση KDE Desktop Environment ... \n${NC}"
                installer "KDE Desktop" plasma-meta konsole dolphin
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "LXQt")
                echo -e "${IGreen}Εγκατάσταση LXQt Desktop Environment ... \n${NC}"
                installer "LXQt Desktop" lxqt breeze-icons
                installer "SDDM Display Manager" sddm                
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Cinnamon")
                echo -e "${IGreen}Εγκατάσταση Cinnamon Desktop Environment ... \n${NC}"
                installer "Cinnamon Desktop" cinnamon xterm networkmanager
                installer "LightDM Display Manager" lightdm lightdm-gtk-greeter               
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Budgie")
                echo -e "${IGreen}Εγκατάσταση Budgie Desktop Environment ... \n${NC}"
                installer "Budgie Desktop" budgie-desktop budgie-extras xterm networkmanager network-manager-applet
                installer "LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "i3")
                echo -e "${IGreen}Εγκατάσταση i3 Desktop Environment ... \n${NC}"
                installer "i3 Desktop" i3 dmenu rxvt-unicode
                echo -e '#!/bin/bash \nexec i3' > /home/"$USER"/.xinitrc
                exit 0
                ;;
        "Enlightenment")
                echo -e "${IGreen}Εγκατάσταση Enlightenment Desktop Environment ... \n${NC}"
                installer "Enlightenment Desktop" enlightenment terminology connman acpid #acpid and iwd need investigation
                installer "LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable acpid
                sudo systemctl enable connman.service
                exit 0
                ;;
        "UKUI")
                echo -e "${IGreen}Εγκατάσταση UKUI Desktop Environment ... \n${NC}"
                installer "UKUI Desktop" ukui xterm networkmanager network-manager-applet
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Fluxbox")
                echo -e "${IGreen}Εγκατάσταση Fluxbox Desktop Environment ... \n${NC}"
                installer "Fluxbox Desktop" fluxbox xterm menumaker
                echo -e '#!/bin/bash \nstartfluxbox' > /home/"$USER"/.xinitrc
                exit 0
                ;;
        "Sugar")
                echo -e "${IGreen}Εγκατάσταση Sugar Desktop Environment ... \n${NC}"
                installer "Sugar Desktop" sugar sugar-fructose xterm
                installer "LXDM Display Manager" lxdm
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Twm")
                echo -e "${IGreen}Εγκατάσταση Twm Desktop Environment ... \n${NC}"
                installer "Twm Desktop" xorg-twm xterm xorg-xclock
                exit 0
                ;;
		"Έξοδος")
                echo -e "${IYellow}Έξοδος όπως επιλέχθηκε από το χρήστη ${USER}${NC}"
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
	echo -e "${IGreen}7 - Τροποποίηση Γλώσσας και Ζώνης Ώρας${NC}"
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
	echo -e "${IGreen}8 - Ρύθμιση Hostname${NC}           "
	echo '                                             '
	echo 'Θα χρειαστεί να δώσετε ένα όνομα στον        '
	echo 'Υπολογιστή σας                               '
	echo '---------------------------------------------'
	sleep 2
	echo
	read -rp "Δώστε όνομα υπολογιστή (hostname): " hostvar
	echo "$hostvar" > /etc/hostname
	{
		echo "127.0.0.1		localhost"
		echo "127.0.1.1		$hostvar.localdomain $hostvar"
		echo "::1			localhost"
	}> /etc/hosts
	echo
	echo '-------------------------------------'
	echo -e "${IGreen}9 - Ρύθμιση της κάρτας δικτύου${NC}"       
	echo '                                     '
	echo 'Θα ρυθμιστεί η κάρτα δικτύου σας ώστε'
	echo 'να ξεκινάει αυτόματα με την εκκίνηση '
	echo 'του Arch Linux                       '
	echo '-------------------------------------'
	sleep 2
	ethernet=$(ip link | grep "2: "| grep -oE "(en\\w+)")		# Αναζήτηση κάρτας ethernet
	if [ "$ethernet" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα ethernet
		echo
        echo -e "${IYellow}Δε βρέθηκε ενσύρματη κάρτα δικτύου${NC}"				# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		systemctl enable dhcpcd@"$ethernet".service
		echo
        echo -e "${IGreen}Η κάρτα δικτύου $ethernet ρυθμίστηκε επιτυχώς${NC}";
	fi
	wifi=$(ip link | grep ": "| grep -oE "(w\\w+)")			# Αναζήτηση κάρτας wifi
	if [ "$wifi" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα wifi
		echo
        echo -e "${IYellow}Δε βρέθηκε ασύρματη κάρτα δικτύου${NC}"		# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		installer "Ρυθμίσεις Ασύρματης Κάρτας" iw wpa_supplicant dialog netctl wireless-regdb crda # CRDA/wireless-regdb : https://wiki.archlinux.org/index.php/Network_configuration/Wireless#Respecting_the_regulatory_domain
		systemctl enable netctl-auto@"$wifi".service
		echo
        echo -e "${IGreen}Η ασύρματη κάρτα δικτύου $wifi ρυθμίστηκε επιτυχώς${NC}"
	fi
	sleep 2
	echo
	echo '-------------------------------------'
	echo -e "${IGreen}10 - Ρύθμιση χρήστη ROOT${NC}"
	echo '                                     '
	echo 'Αλλαγή συνθηματικού(password)        '
	echo 'του root χρήστη                      '
	echo '-------------------------------------'
	echo
	#########################################################
	until passwd						# Μέχρι να είναι επιτυχής
	do							# η αλλαγή του κωδικού
	    echo							# του root χρήστη, θα
	    echo -e "${IYellow}O root κωδικός δεν άλλαξε, δοκιμάστε ξανά!${NC}"	# τυπώνεται αυτό το μήνυμα
	    echo							#
	done							#
	#########################################################
	echo
	echo '---------------------------------------'
	echo -e "${IGreen}11 - Linux LTS kernel (προαιρετικό)${NC}"
	echo '                                       '
	echo 'Μήπως προτιμάτε τον LTS πυρήνα Linux   '
	echo 'ο οποίος είναι πιο σταθερός και μακράς '
	echo 'υποστήριξης;                           '
	echo '---------------------------------------'
	sleep 2
	if YN_Q "Θέλετε να εγκαταστήσετε πυρήνα μακράς υποστήριξης (Long Term Support) (y/n); "; then
		installer "Linux Lts Kernel" linux-lts
	fi
	echo
	echo '---------------------------------------'
	echo -e "${IGreen}12 - Ρύθμιση GRUB${NC}        "
	echo '                                       '
	echo 'Θα γίνει εγκατάσταση του μενού επιλογών'
	echo 'εκκινησης GRUB Bootloader              '
	echo '---------------------------------------'
	echo
	sleep 2
	installer "Gurb Bootloader" grub efibootmgr os-prober
	lsblk --noheadings --raw -o NAME,MOUNTPOINT | awk '$1~/[[:digit:]]/ && $2 == ""' | grep -oP sd\[a-z]\[1-9]+ | sed 's/^/\/dev\//' > disks.txt
	filesize=$(stat --printf="%s" disks.txt | tail -n1)
	
	cd run 
	mkdir media 
	cd media
	cd /
	if [ "$filesize" -ne 0 ]; then
		num=0
  		while IFS='' read -r line || [[ -n "$line" ]]; do
	        num=$(( num + 1 ))
		    echo $num
		    mkdir /run/media/disk$num
		    mount "$line" /run/media/disk$num && echo -e "${IYellow}Προσαρτάται ο... $num oς δίσκος${NC}"
		    sleep 1
		done < "disks.txt"

		else
		    echo -e "${IYellow}Δεν υπάρχουν άλλοι δίσκοι στο σύστημα${NC}"
	fi
	sleep 5
	rm disks.txt
	
	if [ -d /sys/firmware/efi ]; then
		grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck
		grub-mkconfig -o /boot/grub/grub.cfg
	else
		diskchooser grub
		grub-install --target=i386-pc --recheck "$grubvar"
		grub-mkconfig -o /boot/grub/grub.cfg
	fi
	sleep 2
	echo
	echo '-------------------------------------'
	echo -e "${IGreen}13 - Δημιουργία Χρήστη${NC}"
	echo '                                     '
	echo 'Για την δημιουργία νέου χρήστη θα    '
	echo 'χρειαστεί να δώσετε όνομα/συνθηματικό'
	echo '                                     '
	echo 'Στο χρήστη αυτόν θα δωθούν δικαιώματα'
	echo 'διαχειριστή (sudo)                   '
	echo '-------------------------------------'
	echo
	sleep 2
	read -rp "Δώστε παρακαλώ ένα νέο όνομα χρήστη (λατινικά, μικρά και χωρίς κενά): " onomaxristi
	useradd -m -G wheel -s /bin/bash "$onomaxristi"
	#########################################################
	until passwd "$onomaxristi"	# Μέχρι να είναι επιτυχής
  	do							# η εντολή
	    echo -e "${IYellow}O κωδικός του χρήστη δεν άλλαξε, δοκιμάστε ξανά!${NC}"	# τυπώνεται αυτό το μήνυμα
	    echo
	done
	#########################################################
	echo "$onomaxristi ALL=(ALL) ALL" >> /etc/sudoers
	echo
	echo '--------------------------------------'
	echo -e "${IGreen}14 - Προσθήκη SWAP file${NC}   "
	echo '                                      '
	echo 'Εάν θέλετε, μπορεί να δημιουργηθεί    '
	echo 'SWAP file. Για το μέγεθός του μπορείτε'
	echo 'να γράψετε έναν αριθμό σε MB. π.χ 4096'
	echo 'για να δημιουργηθεί 4GB swap file     '
	echo '--------------------------------------'
	sleep 2
	echo
	if YN_Q "Θέλετε να δημιουργήσετε swapfile (y/n); " "μη έγκυρος χαρακτήρας" ; then
		echo
		read -rp "Τι μέγεθος να έχει το swapfile; (Σε MB) : " swap_size
		echo
        while :		# Δικλείδα ασφαλείας αν ο χρήστης προσθέσει μεγάλο νούμερο.
		do 
			if [ "$swap_size" -ge 512 ] && [ "$swap_size" -le 8192 ]; then
				break
			else
				read -rp "Δώσε μία τιμή από 512 εως 8192 : " swap_size
			fi
		done
		if	[[ "$file_format" == "btrfs" ]]; then
			mount "$diskvar""$diskletter""$disknumber" /mnt
			btrfs subvolume create /mnt/@swap
			umount /mnt
			mkdir /swap
			mount -o subvol=@swap "$diskvar""$diskletter""$disknumber" /swap
			truncate -s 0 /swap/swapfile
			chattr +C /swap/swapfile
			btrfs property set /swap/swapfile compression none 
			dd if=/dev/zero of=/swap/swapfile bs=1M count="$swap_size" status=progress
			chmod 600 /swap/swapfile
			mkswap /swap/swapfile
			echo """$diskvar""""$diskletter""""$disknumber"" /swap btrfs subvol=@swap 0 0 " >> /etc/fstab
			echo "/swap/swapfile none swap defaults 0 0" >> /etc/fstab
		else
			touch /swapfile
			dd if=/dev/zero of=/swapfile bs=1M count="$swap_size" status=progress
			chmod 600 /swapfile
			mkswap /swapfile
			echo '/swapfile none swap defaults 0 0' >> /etc/fstab
		fi
	fi
	echo
	echo '--------------------------------------'
	echo -e "${IGreen}BONUS - Εγκατάσταση Desktop${NC}"
	echo '                                      '
	echo 'Θέλετε να εγκαταστήσετε κάποιο γραφικό'
	echo 'περιβάλλον  ;                         '
	echo '                                      '
	echo -e "         ${IGreen}ΣΗΜΑΝΤΙΚΟ:${NC}  "
	echo 'Τα διαθέσιμα γραφικά περιβάλλοντα     '
	echo 'είναι ΜΟΝΟ από τα επίσημα αποθετήρια  '
	echo 'και όχι από το AUR. Όποιο και αν      '
	echo 'διαλέξετε, θα εγκατασταθεί ΜΟΝΟ το    '
	echo 'γραφικό περιβάλλον με βάση τις        '
	echo 'επίσημες KISS οδηγίες του Arch Wiki   '
	echo '--------------------------------------'
	sleep 2
    echo
	############# Installing Desktop ###########
	if YN_Q "Θέλετε να συνεχίσετε (y/n); " "μη έγκυρος χαρακτήρας" ; then
		echo
		echo -e "${IYellow}Έναρξη της εγκατάστασης${NC}"
		check_if_in_VM
    	initialize_desktop_selection
	else
        echo '--------------------------------------------------------'
        echo -e "${IGreen} Τέλος εγκατάστασης${NC}                    "
        echo ' Μπορείτε να επανεκκινήσετε το σύστημά σας και να κάνετε '
        echo ' εγκατάσταση τις εφαρμογές ή το γραφικό περιβάλλον που'
        echo ' θέλετε...'
        echo '--------------------------------------------------------'
        sleep 5
        exit
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
				echo -e "${2:-"${IYellow}μη έγκυρη απάντηση${NC}"}";;
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
    num=$(( num + 1 ))
    echo "[$num]" "$line"
done < disks
echo "---------------------------------------------------------"
echo
read -rp "Επιλέξτε δίσκο για εγκατάσταση (Q/q για έξοδο): " input

if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   	then
        echo
	    echo -e "${IYellow}Έξοδος...${NC}"
	    tput cnorm   -- normal  	# Εμφάνιση cursor
	exit 0
fi

if [ "$input" -gt 0 ] && [ "$input" -le $num ]; #έλεγχος αν το input είναι μέσα στο εύρος της λίστας
	then
	if [[ $1 = "grub" ]];		# αν προστεθεί το όρισμα grub τότε η μεταβλητή που θα αποθηκευτεί
	    then				# θα είναι η grubvar
	    grubvar="/dev/"$(cat < disks | head -n$(( input )) | tail -n1 )
	    echo Διάλεξατε τον "$grubvar"
	else
	    diskvar="/dev/"$(cat < disks | head -n$(( input )) | tail -n1 )
		if [[ "$diskvar" = *"/dev/nvme0n"[1-9]* ]]; then	#Εκχώρηση τιμής στην diskletter αν είναι nvme ο δίσκος.
			diskletter="p"
		fi
	    echo Διάλεξατε τον "$diskvar"
	fi
	break
else
	echo -e "${IYellow}Αριθμός εκτός λίστας${NC}"
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
	echo
    echo -e "${IRed}Λυπάμαι, αλλά πρέπει να είσαι root χρήστης για να τρέξεις το Archon.${NC}"
	echo -e "${IYellow}Έξοδος...${NC}"
	echo
    sleep 2
	exit 1
fi
#Τυπικός έλεγχος για το αν το τρέχει σε Arch.
if [ ! -f /etc/arch-release ] ; then
	echo
    echo -e "${IRed}Λυπάμαι, αλλά το σύστημα στο οποίο τρέχεις το Archon δεν είναι Arch Linux${NC}"
	echo -e "${IYellow}Έξοδος...${NC}"
	echo
    sleep 2
	exit
fi

setfont gr928a-8x16.psfu
echo -e "----------------------${IGreen} Archon ${NC}--------------------------"
echo "     _____                                              ";
echo "  __|_    |__  _____   ______  __   _  _____  ____   _  ";
echo " |    \      ||     | |   ___||  |_| |/     \|    \ | | ";
echo " |     \     ||     \ |   |__ |   _  ||     ||     \| | ";
echo " |__|\__\  __||__|\__\|______||__| |_|\_____/|__/\____| ";
echo "    |_____|                                             ";
echo "                                                        ";
echo -e "${IYellow}         Ο πρώτος Ελληνικός Arch Linux Installer        ${NC}";
echo '--------------------------------------------------------'
sleep 1
echo ' Σκοπός αυτού του cli εγκαταστάτη είναι η εγκατάσταση του'
echo ' βασικού συστήματος Arch Linux ΧΩΡΙΣ γραφικό περιβάλλον.'
echo ''
echo ' Η διαδικασία ολοκληρώνεται σε 14 βήματα'
echo ''
echo ' Προτείνεται η εγκατάσταση σε ξεχωριστό δίσκο για την '
echo ' αποφυγή σπασίματος του συστήματος σας. '
echo ''
echo -e "${IYellow} Το script αυτό παρέχεται χωρίς καμιάς μορφής εγγύηση${NC}"
echo -e "${IYellow} σωστής λειτουργίας.${NC}"
echo ''
echo ' You have been warned !!!'
sleep 5
echo
if YN_Q "Θέλετε να συνεχίσετε (y/n); " "μη έγκυρος χαρακτήρας" ; then
	echo
	echo -e "${IYellow}Έναρξη της εγκατάστασης${NC}"
else
    echo
	echo -e "${IYellow} Έξοδος...${NC}"
	exit 0
fi
echo
sleep 1
echo '---------------------------------------'
echo -e "${IGreen} 1 - Έλεγχος σύνδεσης στο διαδίκτυο${NC}"
echo '---------------------------------------'
if ping -c 3 www.google.com &> /dev/null; then
  echo
  echo -e "${IYellow}Υπάρχει σύνδεση στο διαδίκτυο${NC}"
  echo ' Η εγκατάσταση θα συνεχιστεί'
  echo
else
    echo
	echo -e "${IRed}Δεν βρέθηκε σύνδεση στο διαδίκτυο! Συνδεθείτε στο διαδίκτυο και δοκιμάστε ξανά${NC}"
	echo
    sleep 1
	echo -e "${IYellow} Έξοδος...${NC}"
	echo
    sleep 1
	exit 1
fi
sleep 1
echo
echo
echo '----------------------------------------------'
echo -e "${IGreen} 2 - Παρακάτω βλέπετε τους διαθέσιμους δίσκους${NC}"
echo '                                              '
echo ' Επιλέξτε τον αριθμό δίσκου στον οποίο θα '
echo ' γίνει η εγκατάσταση του Arch Linux           '
echo '----------------------------------------------'
echo
diskchooser
echo
echo '--------------------------------------------------------'
echo -e "${IYellow} Η εγκατάσταση θα γίνει στον $diskvar ${NC}"
echo '--------------------------------------------------------'
sleep 1
echo
echo '---------------------------------------------'
echo -e "${IGreen} 3 - Γίνεται έλεγχος αν το σύστημά σας είναι${NC}"
echo '                                             '
echo '              BIOS ή UEFI                    '
echo '---------------------------------------------'
sleep 1
set -e
################### Check if BIOS or UEFI #####################

if [ -d /sys/firmware/efi ]; then  #Η αρχική συνθήκη παραμένει ίδια
	echo
	echo -e "${IYellow} Χρησιμοποιείς PC με UEFI${NC}";
	echo
	sleep 1
	parted "$diskvar" mklabel gpt
	parted "$diskvar" mkpart ESP fat32 1MiB 513MiB
	parted "$diskvar" mkpart primary ext4 513MiB 100%
	disknumber="1"		# Η τιμή 1 γιατί θέλουμε το 1ο partition 
	mkfs.fat -F32 "$diskvar""$diskletter""$disknumber"
	disknumber="2"		# Στο δεύτερο partition κάνει mount το /mnt στην filesystem.
	filesystems
	disknumber="1"		# Προσοχή οι γραμμές 646-647 αν μπουν πάνω από την filesystem υπάρχει πρόβλημα στο boot.
	mkdir "/mnt/boot"
	mount "$diskvar""$diskletter""$disknumber" "/mnt/boot"
	disknumber="2"	# Θα χρειαστεί στο swapfile το δεύτερο partition
	sleep 1
else
	echo
	echo -e "${IYellow} Χρησιμοποιείς PC με BIOS${NC}";
	echo
	sleep 1
	########## Υποστηριξη GPT για BIOS συστήματα ##########
	echo
    echo -e "${IYellow}Θα θέλατε GPT Partition scheme ή MBR${NC}"
	echo
	PS3="Επιλογή partition scheme: "
	options=("MBR" "GPT")
	select opt in "${options[@]}"
	do
		case $opt in
			"MBR")
				parted "$diskvar" mklabel msdos
				parted "$diskvar" mkpart primary ext4 1MiB 100%
				disknumber="1"
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
			*) echo -e "${IRed}Οι επιλογές σας πρέπει να είναι [1 ή 2]. Παρακαλώ προσπαθήστε ξανα!${NC}";;
		esac
	done
fi

sleep 1
echo
echo '--------------------------------------------------------'
echo -e "${IGreen} 4 - Ανανέωση πηγών λογισμικού (Mirrors)${NC}  "
echo '--------------------------------------------------------'
sleep 1
pacman -Syy
echo
echo '--------------------------------------------------------'
echo -e "${IGreen} 5 - Εγκατάσταση της Βάσης του Arch Linux${NC} "
echo '                                                        '
echo -e "${IYellow} Αν δεν έχετε κάνει ακόμα καφέ τώρα είναι η ευκαιρία...${NC}"
echo '--------------------------------------------------------'
sleep 2
pacstrap /mnt base base-devel linux linux-firmware dhcpcd "$fsprogs"
echo
echo '--------------------------------------------------------'
echo -e "${IGreen} 6 - Ολοκληρώθηκε η βασική εγκατάσταση του Arch Linux${NC}"
echo '                                                        '
echo ' Τώρα θα γίνει είσοδος στο εγκατεστημένο Arch Linux     '
echo '--------------------------------------------------------'
sleep 1
# Μεταβλητές που χρειάζονται όταν το file_format="btrfs" στο arch-chroot
if [[ "$file_format" == "btrfs" ]]; then
	export file_format="$file_format"
	export diskvar="$diskvar"
	export disknumber="$disknumber"
	export diskletter="$diskletter"
fi
cp archon.sh /mnt/archon.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./archon.sh --stage chroot
rm /mnt/archon.sh #διαγραφή του script από το / του συστήματος
echo
echo '--------------------------------------------------------'
echo -e "${IGreen} Τέλος εγκατάστασης${NC}                    "
echo ' Μπορείτε να επανεκκινήσετε το σύστημά σας              '
echo '--------------------------------------------------------'
sleep 5
exit
