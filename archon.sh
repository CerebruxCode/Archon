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
# Χρώματα και Περιγράμματα
reset=`tput sgr0`				#Επαναφορά έντονο Λευκό
red=`tput setaf 1`				#Σκουρο Κόκκινο
green=`tput setaf 2`			#Πράσινο
orange=`tput setaf 3`			#Πορτοκαλί
blue=`tput setaf 4`				#Σκούρο Μπλέ
purple=`tput setaf 5`			#Μωβ
cyan=`tput setaf 6`				#Ανοιχτό Γαλάζιο
offwhite=`tput setaf 7`			#Εκρού Λευκό
gray=`tput setaf 8`				#Γκρι
coral=`tput setaf 9`			#Κοραλί
lines=$(printf "%0.s▒" {1..64})	#Σχεδίαση γραμμής περιγράμματος
slim="--------------------------------------------------------"
tabs=$(printf "\t\t\t\t\t")		#Πολλαπλά Tab
#
# ########## Function Επιλογή γλώσσας ##########
function language {
	clear
	menu_language=$(printf "\n\n\n\n\n\n\n\n\n\n$tabs${blue}$lines\n$tabs▒                       ${cyan}%2s[1] Ελληνικά %2s${blue}                      ▒\n$tabs▒                       ${cyan}%2s[2] English  %2s${blue}                      ▒\n$tabs$lines")
	printf "$menu_language"
	while true
	 do
		read -n1 epilogi #Επιλογή χωρίς τη χρήση του enter
		case $epilogi in
			[1] )
				input="lang_gr.txt"
				break
				;;
			[2] )
				input="lang_en.txt"
				break
				;;
			* )
				clear
				printf "$menu_language"
				;;
		esac
	 done
	while IFS= read -r line
	 do
		str_lang+=("$line")
	 done < "$input"
	printf "\n"
#	printf "%2s${red}${str_lang[0]}\n" #Εμφάνιση ανάλογου μηνύματος με χρώμα
lines=$(printf "%0.s▒" {1..64})	#Σχεδίαση γραμμής περιγράμματος
tabs=$(printf "\t\t\t\t\t")		#Πολλαπλά Tab
}
# ########## Function logoArchon ##########
function logoArchon {
	clear
	printf "\b$tabs${cyan}-----------------${green} Archon   Ver 4.0 ® ${cyan}-------------------\n"
	printf "$tabs     _____                                              \n";
	printf "$tabs  __|_    |__  _____   ______  __   _  _____  ____   _  \n";
	printf "$tabs |    \      ||     | |   ___||  |_| |/     \|    \ | | \n";
	printf "$tabs |     \     ||     \ |   |__ |   _  ||     ||     \| | \n";
	printf "$tabs |__|\__\  __||__|\__\|______||__| |_|\_____/|__/\____| \n";
	printf "$tabs    |_____|                                             \n";
	printf "$tabs                                                        \n";
	printf "$tabs${coral}         ${str_lang[84]}        ${reset}\n";
	printf "$tabs${cyan}$slim${offwhite}\n"
	sleep 1
	printf "$tabs${str_lang[85]}\n"
	printf "$tabs${str_lang[86]}\n"
	printf "$tabs${str_lang[87]}\n"
	printf "$tabs${str_lang[88]}\n"
	printf "$tabs${str_lang[89]}\n"
	printf "$tabs${red}${str_lang[90]}\n"
	printf "$tabs${red}${str_lang[91]}\n"
	printf "\n$tabs${reset}${str_lang[92]}\n"
}
# ########## Filesystem Function ##########
function filesystems() {
	menu_filesystem=$(printf "$tabs${blue}$lines\n$tabs▒                       ${cyan}%2s${str_lang[0]}%2s${blue}                      ▒\n$tabs$tabs${blue}$lines\n$tabs▒                       ${cyan}%2s[1] ext4 %2s${blue}                      ▒\n$tabs▒                       ${cyan}%2s[2] XFS %2s${blue}                      ▒\n$tabs▒                       ${cyan}%2s[3] Btrfs %2s${blue}                      ▒\n$tabs▒                       ${cyan}%2s[4] F2FS  %2s${blue}                      ▒\n$tabs$lines")
	while true
	 do
	 	read -n1 option #Επιλογή χωρίς τη χρήση του enter
		case $opt in
			[1] )
				fsprogs="e2fsprogs"
				mkfs.ext4 "$diskvar""$disknumber"
				if [[ "$disknumber" == "1" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == "2" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
			[2] )
			    fsprogs="xfsprogs"
				mkfs.xfs "$diskvar""$disknumber"
				if [[ "$disknumber" == "1" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == "2" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
			[3] )
				fsprogs="btrfs-progs"
				mkfs.btrfs "-f" "$diskvar""$disknumber"
				if [[ "$disknumber" == "1" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == "2" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
			[4] )
				fsprogs="f2fs-tools"
				mkfs.f2fs "-f" "$diskvar""$disknumber"
				if [[ "$disknumber" == "1" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == "2" ]]; then
						mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
			* ) clear
				printf "$menu_language"
				;;
		esac
	done
}
# ########## Function έλέγχου εγκατάστασης σε PC ή VM ##########
function check_if_in_VM() {
    echo -e "${IGreen}Έλεγχος περιβάλλοντος (PC | VM) ...${NC}"
    sleep 2
    pacman -S --noconfirm facter
    if [[ $(facter 2>/dev/null | grep 'is_virtual' | awk -F'=> ' '{print $2}') == true ]]
     then
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
# ########## Function Εγκαταστάτης Προγραμμάτων ##########
function installer() {
    echo -e "${IGreen}Εγκατάσταση $1 ...${NC}"
    if pacman -S --noconfirm $2
     then
     	echo -e "${IGreen}[ ΕΠΙΤΥΧΗΣ ] Εγκατάσταση $1 ...${NC}"
     else
     	echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση $1 ...${NC}"
	fi
}
# ########## Function Ελέγχου σύνδεσης στο internet ##########
function check_net_connection {
	printf "$tabs${reset}$slim\n"
	printf "$tabs${green}${str_lang[93]}\n"
	if ping -c 3 www.google.com &> /dev/null
	 then
		printf "$tabs${orange}${str_lang[94]}\n"
		printf "\b$tabs${reset}${str_lang[95]}\n"
	 else
		printf "$tabs${red}${str_lang[96]}${str_lang[97]}${reset}\n"
		sleep 1
		echo -e "$tabs${orange} ${str_lang[78]}${reset}\n"
		sleep 1
		exit 1
	fi
}
# ########## Function επιλογής δίσκου πιο failsafe για αποφυγή λάθους #######
function diskchooser() {
	lsblk --noheadings --raw | grep disk | awk '{print $1}' > disks
	while true
	 do
#		printf "$tabs$slim\n"
		num=0
		while IFS='' read -r line || [[ -n "$line" ]]
	 	 do
			num=$(( $num + 1 ))
			printf "$tabs[$num] $line\n"
		done < disks
		printf "\n"
		read -rp "$tabs${str_lang[80]} [1 ~ $num] - ${str_lang[118]}" input
		if [[ $input = "q" ]] || [[ $input = "Q" ]]
   		 then
			printf "$tabs${orange}${str_lang[78]}${reset}\n\n\n"
			tput cnorm   -- normal  	# Εμφάνιση cursor
			exit 0
		fi
		if [ $input -gt 0 ] && [ $input -le $num ]; #έλεγχος αν το input είναι μέσα στο εύρος της λίστας
		 then
			if [[ $1 = "grub" ]];		# αν προστεθεί το όρισμα grub τότε η μεταβλητή που θα αποθηκευτεί
			 then				# θα είναι η grubvar
				grubvar="/dev/"$(cat disks | head -n$(( $input )) | tail -n1 )
				printf "$tabs${orange}${str_lang[117]} $grubvar${reset}"
			 else
				diskvar="/dev/"$(cat disks | head -n$(( $input )) | tail -n1 )
				printf "$tabs${orange}${str_lang[117]} $diskvar${reset}"
			fi
			break
		 else
			printf "$tabs${red}${str_lang[81]} [1 ~ $num] - ${str_lang[118]}"
			printf "\n$tabs${str_lang[109]}${reset}\n"
			sleep 2
		fi
	done
	rm disks
	printf "\n"
}
export -f diskchooser
# ########## Function για UEFI ##########
function UEFI () {
	if  [ "$diskvar" = "/dev/sd*" ]
	 then
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
# ########## Function για BIOS ##########
function BIOS () {
	if [ "$diskvar" = "/dev/sd*" ]
	 then
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
		sleep 1
	fi
}
# ########## Function για έλεγχο αν έχεις BIOS ή UEFI ##########
function check_system {
	menu_GTP_MBR=$(printf "$tabs$slim\n$tabs|                        [1] MBR                       |\n$tabs|                        [2] GPT                       |\n$tabs$slim")
	if [ -d /sys/firmware/efi ]
	 then  #Η αρχική συνθήκη παραμένει ίδια
		printf "\n$tabs${orange}${str_lang[104]}${reset}\n"
		sleep 1
		UEFI   #Συνάρτηση για UEFI, αν προστεθεί sd? ή nvme? (line 311-333)
	 else
		printf "$tabs${orange}${str_lang[105]}${reset}\n"
# ########## Υποστήριξη GPT για BIOS συστήματα ##########
		printf "$tabs${reset}${str_lang[106]}${reset}\n"
		printf "$menu_GTP_MBR"
		while true
	 	 do
	 		read -n1 epilogi #Επιλογή χωρίς τη χρήση του enter
			case $epilogi in
				[1] )
					disknumber="1"
					parted "$diskvar" mklabel msdos
					parted "$diskvar" mkpart primary ext4 1MiB 100%
					filesystems
					break
					;;
				[2] )
					disknumber="2"
					parted "$diskvar" mklabel gpt
					parted "$diskvar" mkpart primary 1 3
					parted "$diskvar" set 1 bios_grub on
					parted "$diskvar" mkpart primary ext4 3MiB 100%
					filesystems
					break
					;;
				*)	printf "\n$tabs${red}${str_lang[108]}"
					printf "\n$tabs${str_lang[109]}${reset}\n"
					printf "\n$tabs${reset}${str_lang[106]}${reset}\n"
					printf "$menu_GTP_MBR"
					;;
			esac
		 done
	fi
}
# ########## Function για Desktop και X Dsiplay server (X-Org) ##########
function initialize_desktop_selection() {
	sleep 2
    installer "Xorg Server" "xorg xorg-server xorg-xinit alsa-utils alsa-firmware pulseaudio noto-fonts"		# Εγκατάσταση Xorg Server
    PS3='Επιλέξτε ένα από τα διαθέσιμα γραφικά περιβάλλοντα : '

	options=("GNOME" "Mate" "Deepin" "Xfce" "KDE" "LXQt" "Cinnamon" "Budgie" "i3" "Enlightenment" "UKUI" "Fluxbox" "Sugar" "Twm" "Έξοδος")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")
                echo -e "${IGreen}Εγκατάσταση GNOME Desktop Environment ...\n${NC}"
                installer "GNOME Desktop" "gnome gnome-extra"
                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 		"Mate")
                echo -e "${IGreen}Εγκατάσταση Mate Desktop Environment ... \n${NC}"
                installer "Mate Desktop" "mate mate-extra networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Deepin")
                echo -e "${IGreen}Εγκατάσταση Deepin Desktop Environment ...\n${NC}"
                installer "Deepin Desktop" "deepin deepin-extra networkmanager"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Xfce")
                echo -e "${IGreen}Εγκατάσταση Xfce Desktop Environment ... \n${NC}"
                installer "Xfce Desktop" "xfce4 xfce4-goodies pavucontrol networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "KDE")
                echo -e "${IGreen}Εγκατάσταση KDE Desktop Environment ... \n${NC}"
                installer "KDE Desktop" "plasma-meta konsole dolphin"
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "LXQt")
                echo -e "${IGreen}Εγκατάσταση LXQt Desktop Environment ... \n${NC}"
                installer "LXQt Desktop" "lxqt breeze-icons"
                installer "SDDM Display Manager" "sddm"                
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Cinnamon")
                echo -e "${IGreen}Εγκατάσταση Cinnamon Desktop Environment ... \n${NC}"
                installer "Cinnamon Desktop" "cinnamon xterm networkmanager"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"                
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Budgie")
                echo -e "${IGreen}Εγκατάσταση Budgie Desktop Environment ... \n${NC}"
                installer "Budgie Desktop" "budgie-desktop budgie-extras xterm networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "i3")
                echo -e "${IGreen}Εγκατάσταση i3 Desktop Environment ... \n${NC}"
                installer "i3 Desktop" "i3 dmenu rxvt-unicode"
                echo -e '#!/bin/bash \nexec i3' > /home/$USER/.xinitrc
                exit 0
                ;;
        "Enlightenment")
                echo -e "${IGreen}Εγκατάσταση Enlightenment Desktop Environment ... \n${NC}"
                installer "Enlightenment Desktop" "enlightenment terminology connman"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable connman.service
                exit 0
                ;;
        "UKUI")
                echo -e "${IGreen}Εγκατάσταση UKUI Desktop Environment ... \n${NC}"
                installer "UKUI Desktop" "ukui xterm networkmanager network-manager-applet"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Fluxbox")
                echo -e "${IGreen}Εγκατάσταση Fluxbox Desktop Environment ... \n${NC}"
                installer "Fluxbox Desktop" "fluxbox xterm menumaker"
                echo -e '#!/bin/bash \nstartfluxbox' > /home/$USER/.xinitrc
                exit 0
                ;;
        "Sugar")
                echo -e "${IGreen}Εγκατάσταση Sugar Desktop Environment ... \n${NC}"
                installer "Sugar Desktop" "sugar sugar-fructose xterm"
                installer "LXDM Display Manager" "lxdm"
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Twm")
                echo -e "${IGreen}Εγκατάσταση Twm Desktop Environment ... \n${NC}"
                installer "Twm Desktop" "xorg-twm xterm xorg-xclock"
                exit 0
                ;;
		"Έξοδος")
                echo -e "${IYellow}Έξοδος όπως επιλέχθηκε από το χρήστη "${USER}"${NC}"
                exit 0
                ;;
            *)
                echo -e "${IRed}Οι επιλογές σας πρέπει να είναι [1 ~ 14]. Παρακαλώ προσπαθήστε ξανα!${NC}"
                ;;
        esac
	done
}
# ########## Function Βασικής Εγκατάστασης του arch linux ##########
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
	echo
	sleep 2
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
		echo -e "${IYellow}Δε βρέθηκε ενσύρματη κάρτα δικτύου${NC}"				# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		   systemctl enable dhcpcd@"$ethernet".service
		echo -e "${IGreen}Η κάρτα δικτύου $ethernet ρυθμίστηκε επιτυχώς${NC}";
	fi
	echo
	wifi=$(ip link | grep ": "| grep -oE "(w\\w+)")			# Αναζήτηση κάρτας wifi
	if [ "$wifi" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα wifi
		echo -e "${IYellow}Δε βρέθηκε ασύρματη κάρτα δικτύου${NC}"		# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		pacman -S --noconfirm iw wpa_supplicant dialog wpa_actiond
		systemctl enable netctl-auto@"$wifi".service
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
	sleep 1
	#########################################################
	until passwd						# Μέχρι να είναι επιτυχής
	do							# η αλλαγή του κωδικού
	echo							# του root χρήστη, θα
	echo -e "${IYellow}O root κωδικός δεν άλλαξε, δοκιμάστε ξανά!${NC}"	# τυπώνεται αυτό το μήνυμα
	echo							#
	done							#
	#########################################################
	sleep 2
	echo
	echo
	echo '---------------------------------------'
	echo -e "${IGreen}11 - Linux LTS kernel (προαιρετικό)${NC}"
	echo '                                       '
	echo 'Μήπως προτιμάτε τον LTS πυρήνα Linux   '
	echo 'ο οποίος είναι πιο σταθερός και μακράς '
	echo 'υποστήριξης;                           '
	echo '---------------------------------------'
	sleep 2
	if YesNo "Θέλετε να εγκαταστήσετε πυρήνα μακράς υποστήριξης (Long Term Support) (y/n); "; then
		sudo pacman -S --noconfirm linux-lts
	fi
	echo
	echo
	echo '---------------------------------------'
	echo -e "${IGreen}12 - Ρύθμιση GRUB${NC}        "
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
	if [ $filesize -ne 0 ]
	 then
		num=0
  		while IFS='' read -r line || [[ -n "$line" ]]
  		 do
	        num=$(( $num + 1 ))
		    echo $num
		    mkdir /run/media/disk$num
		    mount $line /run/media/disk$num | echo -e "${IYellow}Προσαρτάται ο..."$num"oς δίσκος${NC}"
		    sleep 1
		 done < "disks.txt"
	 else
	 	echo -e "${IYellow}Δεν υπάρχουν άλλοι δίσκοι στο σύστημα${NC}"
	fi
	sleep 5
	rm disks.txt
	if [ -d /sys/firmware/efi ]
	 then
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
#	#########################################################
	echo "$onomaxristi ALL=(ALL) ALL" >> /etc/sudoers
	echo
	echo
	echo '-------------------------------------'
	echo -e "${IGreen}14 - Προσθήκη Multilib${NC} "
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
	echo -e "${IGreen}15 - Προσθήκη SWAP${NC}   "
	echo '                                      '
	echo 'Θα χρησιμοποιηθεί το systemd-swap αντί'
	echo 'για διαμέρισμα SWAP ώστε το μέγεθός   '
	echo 'του να μεγαλώνει εάν και εφόσoν το    '
	echo 'απαιτεί το σύστημα                    '
	echo '--------------------------------------'
	sleep 2
# ########## Installing Zswap ##########
	pacman -S --noconfirm systemd-swap
# τα default του developer αλλάζουμε μόνο:
	echo
	{
			echo "zswap_enabled=0"
			echo "swapfc_enabled=1"
	} >> /etc/systemd/swap.conf.d/systemd-swap.conf
	systemctl enable systemd-swap
	echo ""
	echo '--------------------------------------'
	echo -e "${IGreen}BONUS - Εγκατάσταση Desktop${NC}"
	echo '                                      '
	echo 'Θέλετε να εγκαταστήσετε κάποιο γραφικό'
	echo 'περιβάλλον  ;                         '
	echo '                                      '
	echo -e "         ${IGreen}ΣΗΜΑΝΤΙΚΟ:${NC}     "
	echo 'Τα διαθέσιμα γραφικά περιβάλλοντα     '
	echo 'είναι ΜΟΝΟ από τα επίσημα αποθετήρια  '
	echo 'και όχι από το AUR. Όποιο και αν      '
	echo 'διαλέξετε, θα εγκατασταθεί ΜΟΝΟ το    '
	echo 'γραφικό περιβάλλον με βάση τις        '
	echo 'επίσημες KISS οδηγίες του Arch Wiki   '
	echo '--------------------------------------'
	sleep 2
	############# Installing Desktop ###########
	if YesNo "Θέλετε να συνεχίσετε (y/n); " "μη έγκυρος χαρακτήρας" ; then
		echo ""
		echo -e "${IYellow}Έναρξη της εγκατάστασης${NC}"
		check_if_in_VM
    	initialize_desktop_selection
	else
		echo -e "${IYellow}Έξοδος...${NC}"
		exit 0
	fi
}
# ########## Function YesNo (Yes/No) ##########
function YesNo {
	printf "$1"
	while true
	 do
		read -n1 epilogi #Επιλογή χωρίς τη χρήση του enter
		case $epilogi in
			[yY] )
				return 0
				break
				;;
			[nN] )
				return 1
				break
				;;
			* )
				printf "$1"
				;;
		esac
	 done
}
# ########## MAIN PROGRAM - ΚΥΡΙΟΣ ΠΡΟΓΡΑΜΜΑ ##########
setfont gr928a-8x16.psfu
# ########## Έλεγχος chroot ##########
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
language
logoArchon
sleep 5
if YesNo "\n\n$tabs${reset}${str_lang[75]}\n"
 then
 	clear
	printf "$tabs$slim\n"
	printf "\b$tabs               ${green}${str_lang[77]}${reset}\n"
 else
 	clear
	printf "\n\n$tabs${coral}${str_lang[78]}%{reset}\n"
	exit 0
fi
sleep 1
check_net_connection
sleep 1
printf "\n\n"
printf "$tabs$slim\n"
printf "$tabs${green}${str_lang[98]}${reset}\n"
printf "$tabs${str_lang[99]}\n"
printf "$tabs${str_lang[100]}           \n"
diskchooser
printf "$tabs${str_lang[101]} $diskvar\n\n"
sleep 1
printf "$tabs$slim\n"
printf "$tabs${green}${str_lang[102]} ${str_lang[103]}\n${reset}\n"
sleep 1
set -e
check_system
printf "\n\n$tabs${purple}Μέχρι εδώ έχει φτιαχτεί το πρόγραμμα. . .\n\n"
exit 0 # >>>>>>>>>>		Μέχρι εδώ τρέχει το πρόγραμμα	  >>>>>>>>>>

sleep 1
echo
echo
echo '--------------------------------------------------------'
echo -e "${IGreen} 4 - Ανανέωση πηγών λογισμικού (Mirrors)${NC}  "
echo '--------------------------------------------------------'
pacman -Syy
#pacman -S --noconfirm reflector #απενεργοποίηση λόγω bug του Reflector
#reflector --latest 10 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
#pacman -Syy
sleep 1
echo
echo
echo '--------------------------------------------------------'
echo -e "${IGreen} 5 - Εγκατάσταση της Βάσης του Arch Linux${NC} "
echo '                                                        '
echo -e "${IYellow} Αν δεν έχετε κάνει ακόμα καφέ τώρα είναι η ευκαιρία...${NC}"
echo '--------------------------------------------------------'
sleep 2
pacstrap /mnt base base-devel linux linux-firmware dhcpcd "$fsprogs"
echo
echo
echo '--------------------------------------------------------'
echo -e "${IGreen} 6 - Ολοκληρώθηκε η βασική εγκατάσταση του Arch Linux${NC}"
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
echo -e "${IGreen} Τέλος εγκατάστασης${NC}                       "
echo ' Μπορείτε να επανεκκινήσετε το σύστημά σας              '
echo '--------------------------------------------------------'
sleep 5
exit
