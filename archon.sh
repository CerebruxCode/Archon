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
reset=$(tput sgr0)				#Επαναφορά έντονο Λευκό
red=$(tput setaf 1)				#Σκουρο Κόκκινο
green=$(tput setaf 2)			#Πράσινο
orange=$(tput setaf 3)			#Πορτοκαλί
blue=$(tput setaf 4)				#Σκούρο Μπλέ
purple=$(tput setaf 5)			#Μωβ
cyan=$(tput setaf 6)				#Ανοιχτό Γαλάζιο
offwhite=$(tput setaf 7)			#Εκρού Λευκό
gray=$(tput setaf 8)				#Γκρι
coral=$(tput setaf 9)			#Κοραλί
lines=$(printf "%0.s▒" {1..64})	#Σχεδίαση γραμμής περιγράμματος με ▒
slim=$(printf "%0.s-" {1..56})	#Σχεδίαση γραμμής περιγράμματος με -
tabs=$(printf "\t\t\t\t\t")		#Πολλαπλά Tab
#
# ########## Function Επιλογή γλώσσας ##########
function language {
	clear
	menu_language=$(printf "\n\n\n\n\n\n\n\n\n\n$tabs$blue$lines\n$tabs▒                       $cyan[1] Ελληνικά $blue                      ▒\n$tabs▒                       $cyan[2] English  $blue                      ▒\n$tabs$lines")
	printf "$menu_language"
	while true; do
		read -n1 epilogi #Επιλογή χωρίς τη χρήση του enter
		case $epilogi in
			[1] )
				input='lang_gr.txt'
				break
				;;
			[2] )
				input='lang_en.txt'
				break
				;;
			* )
				clear
				printf "$menu_language"
				;;
		esac
	done
	while IFS= read -r line; do
		str_lang+=("$line")
	done < "$input"
	printf "\n"
}
# ########## Function logoArchon ##########
function logoArchon {
	clear
	printf "\b$tabs%s$cyan-----------------$green Archon   Ver 4.0 ® $cyan-------------------\n"
	printf "$tabs%s     _____                                              \n"
	printf "$tabs%s  __|_    |__  _____   ______  __   _  _____  ____   _  \n"
	printf "$tabs%s |    \      ||     | |   ___||  |_| |/     \|    \ | | \n"
	printf "$tabs%s |     \     ||     \ |   |__ |   _  ||     ||     \| | \n"
	printf "$tabs%s |__|\__\  __||__|\__\|______||__| |_|\_____/|__/\____| \n"
	printf "$tabs%s    |_____|                                             \n"
	printf "$tabs%s                                                        \n"
	printf "$tabs%s$coral         ${str_lang[84]}        $reset\n"
	printf "$tabs%s$cyan$slim$offwhite\n"
	sleep 1
	printf "$tabs%s${str_lang[85]}\n"
	printf "$tabs%s${str_lang[86]}\n"
	printf "$tabs%s${str_lang[87]}\n"
	printf "$tabs%s${str_lang[88]}\n"
	printf "$tabs%s${str_lang[89]}\n"
	printf "$tabs%s$red${str_lang[90]}\n"
	printf "$tabs%s$red${str_lang[91]}\n"
	printf "\n$tabs%s$reset${str_lang[92]}\n"
}
# ########## Filesystem Function ##########
function filesystems() {
	menu_filesystem=$(printf "$tabs%s$blue$lines\n$tabs%s▒                       $cyan${str_lang[0]}$blue                      ▒\n$tabs%s$tabs%s$blue$lines\n$tabs%s▒                       $cyan[1] ext4 $blue                      ▒\n$tabs%s▒                       $cyan[2] XFS $blue                      ▒\n$tabs%s▒                       $cyan[3] Btrfs $blue                      ▒\n$tabs%s▒                       $cyan[4] F2FS  $blue                      ▒\n$tabs%s$lines")
	while true; do
	 	read -n1 option #Επιλογή χωρίς τη χρήση του enter
		case $option in
			[1] )
				fsprogs='e2fsprogs'
				mkfs.ext4 "$diskvar""$disknumber"
				if [[ "$disknumber" == '1' ]]; then
					mount "$diskvar""$disknumber" "/mnt"
				elif [[ "$disknumber" == '2' ]]; then
					mount "$diskvar""$disknumber" "/mnt"
				fi
				break
				;;
			[2] )
			    fsprogs='xfsprogs'
				mkfs.xfs '$diskvar'"$disknumber"
				if [[ "$disknumber" == '1' ]]; then
					mount '$diskvar'"$disknumber" '/mnt'
				elif [[ "$disknumber" == '2' ]]; then
					mount '$diskvar'"$disknumber" '/mnt'
				fi
				break
				;;
			[3] )
				fsprogs='btrfs-progs'
				mkfs.btrfs '-f' '$diskvar'"$disknumber"
				if [[ "$disknumber" == '1' ]]; then
					mount '$diskvar'"$disknumber" '/mnt'
				elif [[ "$disknumber" == '2' ]]; then
					mount '$diskvar'"$disknumber" '/mnt'
				fi
				break
				;;
			[4] )
				fsprogs='f2fs-tools'
				mkfs.f2fs '-f' '$diskvar'"$disknumber"
				if [[ "$disknumber" == '1' ]]; then
					mount '$diskvar'"$disknumber" '/mnt'
				elif [[ "$disknumber" == '2' ]]; then
					mount '$diskvar'"$disknumber" '/mnt'
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
    printf "\n$tabs%s$green${str_lang[3]}$reset"
    sleep 2
    pacman -S --noconfirm facter
    if [[ $(facter 2>/dev/null | grep 'is_virtual' | awk -F'=> ' '{print $2}') == true ]]; then
    	printf "\n$tabs%s$orange${str_lang[4]}$reset"
		sleep 2
        pacman -S --noconfirm virtualbox-guest-dkms linux-headers xf86-video-vmware
    else
    	printf "\n$tabs%s$orange${str_lang[5]}$reset"
		sleep 2
        pacman -Rs --noconfirm facter
    fi
    sleep 2
}
# ########## Function Εγκαταστάτης Προγραμμάτων ##########
function installer() {
    printf "\n$tabs%s$green${str_lang[6]} $1...$reset"
    if pacman -S --noconfirm $2; then
		printf "$orange${str_lang[7]} $1...$reset"
	else
     	printf "$orange${str_lang[8]} $1...$reset"
	fi
}
# ########## Function για UEFI ##########
function UEFI () {
	if  [ '$diskvar' = '/dev/sd*' ]; then
		parted '$diskvar' mklabel gpt
		parted '$diskvar' mkpart ESP fat32 1MiB 513MiB
		parted '$diskvar' mkpart primary ext4 513MiB 100%
		mkfs.fat -F32 '$diskvar''1'
		disknumber='2'
		filesystems
		mkdir '/mnt/boot'
		mount '$diskvar''1' '/mnt/boot'
		sleep 1
	else
		parted '$diskvar' mklabel gpt
		parted '$diskvar' mkpart ESP fat32 1MiB 513MiB
		parted '$diskvar' mkpart primary ext4 513MiB 100%
		mkfs.fat -F32 '$diskvar''p1'
		mkfs.ext4 '$diskvar''p2'
		mount '$diskvar''p2' '/mnt'
		mkdir '/mnt/boot'
		mount '$diskvar''p1' '/mnt/boot'
		sleep 1
	fi
}
# ########## Function για BIOS ##########
function BIOS () {
	if [ '$diskvar' = '/dev/sd*' ]; then
		parted '$diskvar' mklabel msdos
		parted '$diskvar' mkpart primary ext4 1MiB 100%
		mkfs.ext4 '$diskvar''1'
		mount '$diskvar''1' '/mnt'
		sleep 1
	else
		parted '$diskvar' mklabel msdos
		parted '$diskvar' mkpart primary ext4 1MiB 100%
		mkfs.ext4 '$diskvar''p1'
		mount '$diskvar''p1' '/mnt' 
		sleep 1
	fi
}
# ########## Function για Desktop και X Dsiplay server (X-Org) ##########
function initialize_desktop_selection() {
	sleep 2
    installer 'Xorg Server' 'xorg xorg-server xorg-xinit alsa-utils alsa-firmware pulseaudio noto-fonts'		# Εγκατάσταση Xorg Server
	menu_desktop=$(printf "$tabs%s$reset--------------------------------------------------------\n$tabs%s$reset|  [ 1] GNOME           [ 2] Mate        [ 3] Deepin   |
$tabs%s$reset|  [ 4] Xfce            [ 5] KDE         [ 6] LXQt     |
$tabs%s$reset|  [ 7] Cinnamon        [ 8] Budgie      [ 9] i3       |
$tabs%s$reset|  [10] Enlightenment   [11] UKUI        [12] Fluxbox  |
$tabs%s$reset|  [13] Sugar           [14] Twm                       |
$tabs%s$reset--------------------------------------------------------\n")
	printf "$menu_desktop\n"
	read -rp '$tabs%s${str_lang[13]} [1 ~ 14] - [q / Q ${str_lang[78]}]' epilogi
	while true; do
		case $epilogi in
			[1] )
            	printf "$tabs%s$orange${str_lang[6]} GNOME Desktop Environment...$reset\n"
                installer 'GNOME Desktop' 'gnome gnome-extra'
                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 			[2] )
                printf "$tabs%s$orange${str_lang[6]} Mate Desktop Environment ...$reset\n"
                installer 'Mate Desktop' 'mate mate-extra networkmanager network-manager-applet'
                installer 'LightDM Display Manager' 'lightdm lightdm-gtk-greeter'
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[3] )
                printf "$tabs%s$orange${str_lang[6]} Deepin Desktop Environment ...$reset\n"
                installer 'Deepin Desktop' 'deepin deepin-extra networkmanager'
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[4] )
                printf "$tabs%s$orange${str_lang[6]} Xfce Desktop Environment ...${resetNC}\n"
                installer 'Xfce Desktop' 'xfce4 xfce4-goodies pavucontrol networkmanager network-manager-applet'
                installer 'LightDM Display Manager' 'lightdm lightdm-gtk-greeter'
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[5] )
                printf "$tabs%s$orange${str_lang[6]} KDE Desktop Environment... $reset\n"
                installer 'KDE Desktop' 'plasma-meta konsole dolphin'
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[6] )
                printf "$tabs%s$orange${str_lang[6]} LXQt Desktop Environment... $reset\n"
                installer 'LXQt Desktop' 'lxqt breeze-icons'
                installer 'SDDM Display Manager' 'sddm'                
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[7] )
                printf "$tabs%s$orange${str_lang[6]} Cinnamon Desktop Environment...$reset\n"
                installer 'Cinnamon Desktop' 'cinnamon xterm networkmanager'
                installer 'LightDM Display Manager' 'lightdm lightdm-gtk-greeter'                
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[8] )
                printf "$tabs%s$orange${str_lang[6]} Budgie Desktop Environment...$reset\n"
                installer 'Budgie Desktop' 'budgie-desktop budgie-extras xterm networkmanager network-manager-applet'
                installer 'LightDM Display Manager' 'lightdm lightdm-gtk-greeter'
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[9] )
                printf "$tabs%s$orange${str_lang[6]} i3 Desktop Environment... $reset\n"
                installer 'i3 Desktop' 'i3 dmenu rxvt-unicode'
                echo -e '#!/bin/bash \nexec i3' > /home/$USER/.xinitrc
                exit 0
                ;;
        	[10] )
                printf "$tabs%s$orange${str_lang[6]} Enlightenment Desktop Environment...$reset\n"
                installer 'Enlightenment Desktop' 'enlightenment terminology connman'
                installer 'LightDM Display Manager' 'lightdm lightdm-gtk-greeter'
                sudo systemctl enable lightdm
                sudo systemctl enable connman.service
                exit 0
                ;;
        	[11] )
                printf "$tabs%s$orange${str_lang[6]} UKUI Desktop Environment... $reset\n"
                installer 'UKUI Desktop' 'ukui xterm networkmanager network-manager-applet'
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[12] )
                printf "$tabs%s$orange${str_lang[6]} Fluxbox Desktop Environment...$reset\n"
                installer 'Fluxbox Desktop' 'fluxbox xterm menumaker'
                echo -e '#!/bin/bash \nstartfluxbox' > /home/$USER/.xinitrc
                exit 0
                ;;
        	[13] )
                printf "$tabs%s$orange${str_lang[6]} Sugar Desktop Environment...$reset\n"
                installer 'Sugar Desktop' 'sugar sugar-fructose xterm'
                installer 'LXDM Display Manager' 'lxdm'
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        	[14] )
                printf "$tabs%s$orange${str_lang[6]} Twm Desktop Environment...$reset\n"
                installer 'Twm Desktop' 'xorg-twm xterm xorg-xclock'
                exit 0
                ;;
            [qQ] )
            	printf "\n\n$tabs%s$red${str_lang[78]}$reset\n"
            	exit 0
            	;;
			* )
                printf "\n$tabs%s$red${str_lang[81]} [1 ~ 14] - [q / Q Έξοδος]"
				printf "\n$tabs%s${str_lang[109]}$reset\n"
 				read -rp '$tabs%s${str_lang[13]} [1 ~ 14] - [q / Q ${str_lang[78]}]' epilogi
 				;;
        esac
	done
}
# ########## Function YesNo (Yes/No) ##########
function YesNo {
	printf "$1"
	while true; do
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
# ##########################################################
# #### ΑΡΧΗ ΤΩΝ FUNCTION ΓΙΑ ΤΑ 15 ΒΗΜΑΤΑ ΕΓΚΑΤΑΣΤΑΣΗΣ #####
# ##########################################################
#
# ########## 1 - Έλεγχος σύνδεσης στο διαδίκτυο ############
function check_net_connection {
	printf "$tabs%s$reset$slim\n"
	printf "$tabs%s$green${str_lang[93]}\n"
	if ping -c 3 www.google.com &> /dev/null; then
		printf "$tabs%s$orange${str_lang[94]}\n"
		printf "\b$tabs%s$reset${str_lang[95]}\n"
	else
		printf "$tabs%s$red${str_lang[96]}${str_lang[97]}$reset\n"
		sleep 1
		echo -e '$tabs%s$orange ${str_lang[78]}$reset\n'
		sleep 1
		exit 1
	fi
}
# ########## 2 - Διαθέσιμοι δίσκοι #######
function diskchooser() {
	lsblk --noheadings --raw | grep disk | awk '{print $1}' > disks
	while true; do
		num=0
		while IFS='' read -r line || [[ -n '$line' ]]; do
			num=$(( $num + 1 ))
			printf "$tabs%s[$num] $line\n"
		done < disks
		printf "\n"
		read -rp '$tabs%s${str_lang[80]} [1 ~ $num] - ${str_lang[118]}' input
		if [[ $input = 'q' ]] || [[ $input = 'Q' ]]; then
			printf "$tabs%s$orange${str_lang[78]}$reset\n\n\n"
			tput cnorm   -- normal  	# Εμφάνιση cursor
			exit 0
		fi
		if [ $input -gt 0 ] && [ $input -le $num ]; then
			if [[ $1 = 'grub' ]]; then
				grubvar='/dev/'$(cat disks | head -n$(( $input )) | tail -n1 )
				printf "$tabs%s$orange${str_lang[117]} $grubvar$reset"
			else
				diskvar='/dev/'$(cat disks | head -n$(( $input )) | tail -n1 )
				printf "$tabs%s$orange${str_lang[117]} $diskvar$reset"
			fi
			break
		else
			printf "$tabs%s$red${str_lang[81]} [1 ~ $num] - ${str_lang[118]}"
			printf "\n$tabs%s${str_lang[109]}$reset\n"
			sleep 2
		fi
	done
	rm disks
	printf "\n"
}
export -f diskchooser
# ########## 3 - 'Ελεγχος αν το σύστημά είναι BIOS ή UEFI ##########
function check_system {
	menu_GTP_MBR=$(printf "$tabs%s$slim\n$tabs%s|                        [1] MBR                       |\n$tabs%s|                        [2] GPT                       |\n$tabs%s$slim")
	if [ -d /sys/firmware/efi ]; then  # Η αρχική συνθήκη παραμένει ίδια
		printf "\n$tabs%s$orange${str_lang[104]}$reset\n"
		sleep 1
		UEFI   #Συνάρτηση για UEFI, αν προστεθεί sd? ή nvme? (line 311-333)
	else
		printf "$tabs%s$orange${str_lang[105]}$reset\n"
		########## Υποστήριξη GPT για BIOS συστήματα ##########
		printf "$tabs%s$reset${str_lang[106]}$reset\n"
		printf "$menu_GTP_MBR"
		while true; do
			read -n1 epilogi #Επιλογή χωρίς τη χρήση του enter
			case $epilogi in
				[1] )
					disknumber='1'
					parted '$diskvar' mklabel msdos
					parted '$diskvar' mkpart primary ext4 1MiB 100%
					filesystems
					break
					;;
				[2] )
					disknumber='2'
					parted '$diskvar' mklabel gpt
					parted '$diskvar' mkpart primary 1 3
					parted '$diskvar' set 1 bios_grub on
					parted '$diskvar' mkpart primary ext4 3MiB 100%
					filesystems
					break
					;;
				* )	
					printf "\n$tabs%s$red${str_lang[108]}"
					printf "\n$tabs%s${str_lang[109]}$reset\n"
					printf "\n$tabs%s$reset${str_lang[106]}$reset\n"
					printf "$menu_GTP_MBR"
					;;
			esac
		 done
	fi
}
function chroot_stage {
# ########## 7 - Τροποποίηση Γλώσσας και Ζώνης Ώρας ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[17]}$reset\n"
	printf "$tabs%s$reset${str_lang[18]}$reset\n"
	printf "$tabs%s$reset${str_lang[19]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
	echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
	locale-gen
	echo LANG=en_US.UTF-8 > /etc/locale.conf
	export LANG=en_US.UTF-8
	ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
	hwclock --systohc
# ########## 8 - Ρύθμιση όνομα υπολογιστή (Hostname) ########## 
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[20]}$reset\n"
	printf "$tabs%s$reset${str_lang[21]}$reset\n"
	printf "$tabs%s$reset${str_lang[22]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
	read -rp '$tabs%s$reset${str_lang[23]} $reset' hostvar
	echo '$hostvar' > /etc/hostname
	sleep 2
# ########## 9 - Ρύθμιση της κάρτας δικτύου ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[24]}$reset\n"
	printf "$tabs%s$reset${str_lang[25]}$reset\n"
	printf "$tabs%s$reset${str_lang[26]}$reset\n"
	printf "$tabs%s$reset${str_lang[27]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
	ethernet=$(ip link | grep '2: '| grep -oE '(en\\w+)') # Αναζήτηση ethernet
	if [ '$ethernet' = '' ]; then # Έλεγχος αν υπάρχει κάρτα ethernet
		printf "$tabs%s$red${str_lang[28]}$reset\n" # αν υπάρχει, εγκατάσταση
	else											# και ενεργοποίηση
		systemctl enable dhcpcd@'$ethernet'.service
		printf "$tabs%s$orange${str_lang[29]} ${str_lang[30]}$reset\n"
	fi
	wifi=$(ip link | grep ': '| grep -oE '(w\\w+)') # Αναζήτηση κάρτας wifi
	if [ '$wifi' = '' ]; then # Έλεγχος αν υπάρχει κάρτα wifi
		printf '$tabs%s$orange${str_lang[31]}$reset\n' # γίνεται εγκατάσταση
	else											   # και ενεργοποίηση
		pacman -S --noconfirm iw wpa_supplicant dialog wpa_actiond
		systemctl enable netctl-auto@'$wifi'.service
		printf "$tabs%s$orange${str_lang[32]} ${str_lang[33]}$reset\n"
	fi
	sleep 2
# ########## 10 - Ρύθμιση χρήστη ROOT ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[34]}$reset\n"
	printf "$tabs%s$reset${str_lang[35]}$reset\n"
	printf "$tabs%s$reset${str_lang[36]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 1
	until passwd    # Μέχρι να είναι επιτυχής η αλλαγή του κωδικού
	 do				# του root χρήστη, θα	
	 	printf "$tabs%s$orange${str_lang[37]}$reset\n"
	 done
# ########## 11 - Linux LTS kernel (προαιρετικό) ##########
	sleep 2
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[38]}$reset\n"
	printf "$tabs%s$reset${str_lang[39]}$reset\n"
	printf "$tabs%s$reset${str_lang[40]}$reset\n"
	printf "$tabs%s$reset${str_lang[41]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
	if YesNo "$tabs%s$reset${str_lang[42]}$reset\n"; then
		sudo pacman -S --noconfirm linux-lts
	fi
# ########## 12 - Ρύθμιση GRUB ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[43]}$reset\n"
	printf "$tabs%s$reset${str_lang[44]}$reset\n"
	printf "$tabs%s$reset${str_lang[45]}$reset\n"
	printf "$reset$tabs%s$slim\n"
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
  		while IFS='' read -r line || [[ -n '$line' ]]; do
	        num=$(( $num + 1 ))
		    echo $num
		    mkdir /run/media/disk$num
		    mount $line /run/media/disk$num | printf "$tabs%s$orange${str_lang[46] $num${str_lang[47]}$reset\n"
		    sleep 1
		done < "disks.txt"
	else
	 	printf "$tabs%s$orange${str_lang[48]}$reset\n"
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
# ########## 13 - Δημιουργία Χρήστη ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[49]}$reset\n"
	printf "$tabs%s$reset${str_lang[50]}$reset\n"
	printf "$tabs%s$reset${str_lang[51]}$reset\n"
	printf "$tabs%s$reset${str_lang[52]}$reset\n"
	printf "$tabs%s$reset${str_lang[53]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
	read -rp '$tabs%s$reset${str_lang[54]}' onomaxristi
	useradd -m -G wheel -s /bin/bash "$onomaxristi"
	until passwd '$onomaxristi'	# Μέχρι να είναι επιτυχής η εντολή
  	 do
		printf "$tabs%s$orange${str_lang[55]}$reset\n"
	 done
	echo '$onomaxristi ALL=(ALL) ALL' >> /etc/sudoers
# ########## 14 - Προσθήκη Multilib ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[56]}$reset\n"
	printf "$tabs%s$reset${str_lang[57]}$reset\n"
	printf "$tabs%s$reset${str_lang[58]}$reset\n"
	printf "$tabs%s$reset${str_lang[59]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
	{
		echo "[multilib]"
		echo "Include = /etc/pacman.d/mirrorlist"
	} >> /etc/pacman.conf
	pacman -Syy
# ########## 15 - Προσθήκη SWAP ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[60]}$reset\n"
	printf "$tabs%s$reset${str_lang[61]}$reset\n"
	printf "$tabs%s$reset${str_lang[62]}$reset\n"
	printf "$tabs%s$reset${str_lang[63]}$reset\n"
	printf "$tabs%s$reset${str_lang[64]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
# ########## Installing Zswap ##########
	pacman -S --noconfirm systemd-swap
	# τα default του developer αλλάζουμε μόνο:
	{
		echo "zswap_enabled=0"
		echo "swapfc_enabled=1"
	} >> /etc/systemd/swap.conf.d/systemd-swap.conf
	systemctl enable systemd-swap
# ########## Εγκατάσταση Desktop ##########
	printf "$reset$tabs%s$slim\n"
	printf "$tabs%s$green${str_lang[65]}$reset\n"
	printf "$tabs%s$reset${str_lang[66]}$reset\n"
	printf "$tabs%s$reset${str_lang[67]}$reset\n"
	printf "$tabs%s$orange${str_lang[68]}$reset\n"
	printf "$tabs%s$reset${str_lang[69]}$reset\n"
	printf "$tabs%s$reset${str_lang[70]}$reset\n"
	printf "$tabs%s$reset${str_lang[71]}$reset\n"
	printf "$tabs%s$reset${str_lang[72]}$reset\n"
	printf "$tabs%s$reset${str_lang[73]}$reset\n"
	printf "$tabs%s$reset${str_lang[74]}$reset\n"
	printf "$reset$tabs%s$slim\n"
	sleep 2
	if YesNo "\n\n$tabs%s$reset${str_lang[75]}\n"; then
		printf "$tabs%s$orange${str_lang[77]}$reset\n"
		check_if_in_VM
    	initialize_desktop_selection
	else
		printf "$redΈξοδος...$reset"
		exit 0
	fi
}
# ########## MAIN PROGRAM - ΚΥΡΙΟΣ ΠΡΟΓΡΑΜΜΑ ##########
setfont gr928a-8x16.psfu
while test $# -gt 0; do ########## Έλεγχος chroot ##########
	case "$1" in
		--stage)
			shift
			if [ "$1" == "chroot" ]
			then
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
if YesNo "\n\n$tabs%s$reset${str_lang[75]}\n"; then
 	clear
	printf "$reset$tabs%s$slim\n"
	printf "\b$tabs%s               $green${str_lang[77]}$reset\n"
else
 	clear
	printf "\n\n$tabs%s$coral${str_lang[78]}%{reset}\n"
	exit 0
fi
sleep 1
check_net_connection
sleep 1
printf "\n\n"
printf "$reset$tabs%s$slim\n"
printf "$tabs%s$green${str_lang[98]}$reset\n"
printf "$tabs%s${str_lang[99]}\n"
printf "$tabs%s${str_lang[100]}           \n"
diskchooser
printf "$tabs%s${str_lang[101]} $diskvar\n\n"
sleep 1
printf "$reset$tabs%s$slim\n"
printf "$tabs%s$green${str_lang[102]} ${str_lang[103]}\n$reset\n"
sleep 1
set -e
check_system
sleep 1
# ########## 4 - Ανανέωση πηγών λογισμικού (Mirrors) ##########
printf "$reset$tabs%s$slim\n"
printf "$tabs%s$green${str_lang[110]}$reset\n"
pacman -Syy
sleep 1
# ########## 5 - Εγκατάσταση της Βάσης του Arch Linux ##########
printf "$reset$tabs%s$slim\n"
printf "$tabs%s$green${str_lang[111]}$reset\n"
printf "$tabs%s$reset${str_lang[112]}$reset\n"
printf "$reset$tabs%s$slim\n"
sleep 2
pacstrap /mnt base base-devel linux linux-firmware dhcpcd "$fsprogs"
# ########## 6 - Ολοκληρώθηκε η βασική εγκατάσταση του Arch Linux ##########
printf "$reset$tabs%s$slim\n"
printf "$tabs%s$green${str_lang[113]}$reset\n"
printf "$tabs%s$reset${str_lang[114]}$reset\n"
printf "$reset$tabs%s$slim\n"
sleep 1
cp archon.sh /mnt/archon.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./archon.sh --stage chroot
printf "$tabs%s$reset$slim\n"
printf "$tabs%s$green${str_lang[115]}$reset\n"
printf "$tabs%s$reset${str_lang[116]}$reset\n"
printf "$tabs%s$reset$slim\n"
sleep 5
exit
