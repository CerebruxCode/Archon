#!/bin/bash
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
# ########## Ο κώδικες των χρωμάτων ##########
IRed='\033[0;91m'                   # Red
IGreen='\033[0;92m'                 # Green
IYellow='\033[0;93m'                # Yellow
IBlue='\033[0;94m'                  # Blue
IPurple='\033[0;95m'                # Purple
ICyan='\033[0;96m'                  # Cyan
IWhite='\033[0;97m'                 # White
NC='\033[0m'                        # Normal Color (Reset)
slim=$(printf '%0.s-' {1..56})      # Γραμμή περιγράμματος
# ########## Δημιουργία μενού διαθέσιμων γλωσσών ##########
function menu_languages {
    tput cup 10 40
	echo -e "$NC$slim"
	tput cup 11 50
	echo -e "$IGreen[1] Ελληνικά"
    tput cup 11 80
	echo -e "$IGreen[2] English"
    tput cup 12 40
	echo -e "$NC$slim"
}
#
# ########## Μενού επιλογής γλώσσας ##########
function language() {
    menu_languages
	while true; do
	    tput cup 13 64
		read -n1 epilogi
		case $epilogi in
			[1] )
				input="lang_gr.txt"
                gr_color="$IYellow"
                en_color="$IWhite"
				break
				;;
			[2] )
				input="lang_en.txt"
                gr_color="$IWhite"
                en_color="$IYellow"
				break
				;;
			* )
				clear
				menu_languages
				;;
		esac
	 done
	while IFS= read -r line; do
	    set -f
		str_lang+=("$line")
    done < "$input"
    tput cup 11 50
	echo -e "${gr_color}[1] Ελληνικά"
    tput cup 11 80
	echo -e "${en_color}[2] English"
    echo -e "${NC}"
    echo
}
########Filesystem Function##################
function filesystems() {
	PS3="${str_lang[0]} "
	options=("ext4" "XFS" "Btrfs" "F2FS")
	select opt in "${options[@]}"
	do
		case $opt in
			"ext4")
				fsprogs="e2fsprogs"
				mkfs.ext4 "$diskvar""$disknumber"
				mount "$diskvar""$disknumber" "/mnt"
				break
				;;
			"XFS")
			  fsprogs="xfsprogs"
				mkfs.xfs "$diskvar""$disknumber"
				mount "$diskvar""$disknumber" "/mnt"
				break
				;;
			"Btrfs")
				fsprogs="btrfs-progs"
				mkfs.btrfs "-f" "$diskvar""$disknumber"
				mount "$diskvar""$disknumber" "/mnt"
				break
				;;
			"F2FS")
				fsprogs="f2fs-tools"
				mkfs.f2fs "-f" "$diskvar""$disknumber"
				mount "$diskvar""$disknumber" "/mnt"
				break
				;;
			*)  echo -e "${IRed}${str_lang[1]}"
			    echo -e "${str_lang[2]}$NC"
			    ;;
			esac
		done
}
########Filesystem End ########################################
######## Functions for Desktop and X Dsiplay server (X-Org)####
#
function check_if_in_VM() {
    echo -e "${IGreen}${str_lang[3]}${NC}"
    sleep 2
    pacman -S --noconfirm facter
    if [[ $(facter 2>/dev/null | grep 'is_virtual' | awk -F'=> ' '{print $2}') == true ]]; then
        echo -e "${IGreen}${str_lang[4]}${NC}"
		sleep 2
        pacman -S --noconfirm virtualbox-guest-dkms linux-headers xf86-video-vmware 
    else
        echo -e "${IGreen}${str_lang[5]}${NC}"
		sleep 2
        pacman -Rs --noconfirm facter
    fi
    sleep 2
}


function installer() {
    echo -e "${IGreen}${str_lang[6]} $1 ...${NC}"
    if pacman -S --noconfirm $2
    then
        echo -e "${IGreen}${str_lang[7]} $1 ...${NC}"
    else
        echo -e "${IRed}${str_lang[8]} $1 ...${NC}"
    fi
}

#  Check Net Connection | If it is off , exit immediately
#
function check_net_connection() {
    sleep 1
    echo '$slim'
    echo -e "${IGreen}${str_lang[9]}${NC}"
    echo '$slim'
    if ping -c 3 www.google.com &> /dev/null; then
        echo -e "${IYellow}${str_lang[10]}${NC}\n"
    else
        echo -e "${IRed}${str_lang[11]}\n"
        echo -e "${str_lang[12]}"
        echo -e "${str_lang[13]}${NC}"
        exit 1
    fi
}

function initialize_desktop_selection() {
	sleep 2
    installer "Xorg Server" "xorg xorg-server xorg-xinit alsa-utils alsa-firmware pulseaudio noto-fonts"	# Εγκατάσταση Xorg Server
    PS3="${str_lang[15]} "

	options=("GNOME" "Mate" "Deepin" "Xfce" "KDE" "LXQt" "Cinnamon" "Budgie" "i3" "Enlightenment" "UKUI" "Fluxbox" "Sugar" "Twm" "Έξοδος")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")
                echo -e "${IGreen}${str_lang[6]} GNOME Desktop Environment ...\n${NC}"
                installer "GNOME Desktop" "gnome gnome-extra"
                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 		"Mate")
                echo -e "${IGreen}${str_lang[6]} Mate Desktop Environment ... \n${NC}"
                installer "Mate Desktop" "mate mate-extra networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Deepin")
                echo -e "${IGreen}${str_lang[6]} Deepin Desktop Environment ...\n${NC}"
                installer "Deepin Desktop" "deepin deepin-extra networkmanager"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Xfce")
                echo -e "${IGreen}${str_lang[6]} Xfce Desktop Environment ... \n${NC}"
                installer "Xfce Desktop" "xfce4 xfce4-goodies pavucontrol networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "KDE")
                echo -e "${IGreen}${str_lang[6]} KDE Desktop Environment ... \n${NC}"
                installer "KDE Desktop" "plasma-meta konsole dolphin"
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "LXQt")
                echo -e "${IGreen}${str_lang[6]} LXQt Desktop Environment ... \n${NC}"
                installer "LXQt Desktop" "lxqt breeze-icons"
                installer "SDDM Display Manager" "sddm"                
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Cinnamon")
                echo -e "${IGreen}${str_lang[6]} Cinnamon Desktop Environment ... \n${NC}"
                installer "Cinnamon Desktop" "cinnamon xterm networkmanager"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"                
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Budgie")
                echo -e "${IGreen}${str_lang[6]} Budgie Desktop Environment ... \n${NC}"
                installer "Budgie Desktop" "budgie-desktop budgie-extras xterm networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "i3")
                echo -e "${IGreen}${str_lang[6]} i3 Desktop Environment ... \n${NC}"
                installer "i3 Desktop" "i3 dmenu rxvt-unicode"
                echo -e '#!/bin/bash \nexec i3' > /home/$USER/.xinitrc
                exit 0
                ;;
        "Enlightenment")
                echo -e "${IGreen}${str_lang[6]} Enlightenment Desktop Environment ... \n${NC}"
                installer "Enlightenment Desktop" "enlightenment terminology connman"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable connman.service
                exit 0
                ;;
        "UKUI")
                echo -e "${IGreen}${str_lang[6]} UKUI Desktop Environment ... \n${NC}"
                installer "UKUI Desktop" "ukui xterm networkmanager network-manager-applet"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Fluxbox")
                echo -e "${IGreen}${str_lang[6]} Fluxbox Desktop Environment ... \n${NC}"
                installer "Fluxbox Desktop" "fluxbox xterm menumaker"
                echo -e '#!/bin/bash \nstartfluxbox' > /home/$USER/.xinitrc
                exit 0
                ;;
        "Sugar")
                echo -e "${IGreen}${str_lang[6]} Sugar Desktop Environment ... \n${NC}"
                installer "Sugar Desktop" "sugar sugar-fructose xterm"
                installer "LXDM Display Manager" "lxdm"
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Twm")
                echo -e "${IGreen}${str_lang[6]} Twm Desktop Environment ... \n${NC}"
                installer "Twm Desktop" "xorg-twm xterm xorg-xclock"
                exit 0
                ;;
		"${str_lang[15]}")
                echo -e "${IYellow}${str_lang[16]} "${USER}"${NC}"
                exit 0
                ;;
            *)
                echo -e "${IRed}${str_lang[17]}"
                echo -e "${str_lang[18]}${NC}"
                ;;
        esac
	done
}
function chroot_stage {
	echo
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[19]}${NC}"
	echo 
	echo -e "${str_lang[20]}"
	echo -e "${str_lang[21]}"
    echo -e "$slim"
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
    echo -e "$slim"
	echo -e "${IGreen}${str_lang[22]}${NC}           "
	echo
	echo -e "${str_lang[23]}"
	echo -e "${str_lang[24]}"
    echo -e "$slim"
	sleep 2
	echo
	read -rp "${str_lang[25]} " hostvar
	echo "$hostvar" > /etc/hostname
	echo
	sleep 2
    echo -e "$slim"
	echo -e "${IGreen}${str_lang[26]}${NC}"       
	echo
	echo -e "${str_lang[27]}"
	echo -e "${str_lang[28]}"
	echo -e "${str_lang[29]}"
    echo -e "$slim"
	sleep 2
	ethernet=$(ip link | grep "2: "| grep -oE "(en\\w+)")		# Αναζήτηση κάρτας ethernet
	if [ "$ethernet" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα ethernet
		echo -e "${IYellow}${str_lang[30]}${NC}"				# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		   systemctl enable dhcpcd@"$ethernet".service
		echo -e "${IGreen}${str_lang[31]} $ethernet ${str_lang[32]}${NC}";
	fi
	echo
	wifi=$(ip link | grep ": "| grep -oE "(w\\w+)")			# Αναζήτηση κάρτας wifi
	if [ "$wifi" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα wifi
		echo -e "${IYellow}${str_lang[33]}${NC}"		# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		pacman -S --noconfirm iw wpa_supplicant dialog wpa_actiond
		systemctl enable netctl-auto@"$wifi".service
		echo -e "${IGreen}${str_lang[34]} $wifi ${str_lang[35]}${NC}"
	fi
	sleep 2
	echo
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[36]}${NC}"
	echo
	echo -e "${str_lang[37]}"
	echo -e "${str_lang[38]}"
	echo -e "$slim"
	echo
	sleep 1
	#########################################################
	until passwd						# Μέχρι να είναι επιτυχής
	do							# η αλλαγή του κωδικού
	echo							# του root χρήστη, θα
	echo -e "${IYellow}${str_lang[39]}${NC}"	# τυπώνεται αυτό το μήνυμα
	echo							#
	done							#
	#########################################################
	sleep 2
	echo
	echo
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[40]}${NC}"
	echo
	echo -e "${str_lang[41]}"
	echo -e "${str_lang[42]}"
	echo -e "${str_lang[43]}"
	echo -e "$slim"
	sleep 2
	if YN_Q "${str_lang[44]} "; then
		sudo pacman -S --noconfirm linux-lts
	fi
	echo
	echo
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[45]}${NC}"
	echo
	echo -e "${str_lang[46]}"
	echo -e "${str_lang[47]}"
    echo -e "$slim"
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
		    mount $line /run/media/disk$num | echo -e "${IYellow}${str_lang[48]}"$num"${str_lang[49]}${NC}"
		    sleep 1
      
		  done < "disks.txt"

		else
		  echo -e "${IYellow}${str_lang[50]}${NC}"
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
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[51]}${NC}"
	echo
	echo "${str_lang[52]}"
	echo "${str_lang[53]}"
	echo
	echo "${str_lang[54]}"
	echo "${str_lang[55]}"
    echo -e "$slim"
	echo
	sleep 2
	read -rp "${str_lang[56]} " onomaxristi
	useradd -m -G wheel -s /bin/bash "$onomaxristi"
	#########################################################
	until passwd "$onomaxristi"	# Μέχρι να είναι επιτυχής
  	do							# η εντολή
	echo -e "${IYellow}${str_lang[57]}${NC}"	# τυπώνεται αυτό το μήνυμα
	echo
	done
	#########################################################
	echo "$onomaxristi ALL=(ALL) ALL" >> /etc/sudoers
	echo
	echo
    echo -e "$slim"
	echo -e "${IGreen}${str_lang[58]}${NC} "
	echo
	echo -e "${str_lang[59]}"
	echo -e "${str_lang[60]}"
	echo -e "${str_lang[61]}"
    echo -e "$slim"
	sleep 2
	echo
	{
		echo "[multilib]"
		echo "Include = /etc/pacman.d/mirrorlist"
	} >> /etc/pacman.conf
	pacman -Syy
    echo -e "$slim"
	echo -e "${IGreen}${str_lang[62]}${NC}"
	echo
	echo -e "${str_lang[63]}"
	echo -e "${str_lang[64]}"
	echo -e "${str_lang[65]}"
	echo -e "${str_lang[66]}"
	echo -e "$slim"
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
	echo ""
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[67]}${NC}"
	echo
	echo -e "${str_lang[68]}"
	echo -e "${str_lang[69]}"
	echo
	echo -e "         ${IGreen}${str_lang[70]}${NC}"
	echo -e "${str_lang[71]}"
	echo -e "${str_lang[72]}"
	echo -e "${str_lang[73]}"
	echo -e "${str_lang[74]}"
	echo -e "${str_lang[75]}"
	echo -e "${str_lang[76]}"
	echo -e "$slim"
	sleep 2
	############# Installing Desktop ###########
	if YN_Q "${str_lang[77]} " "${str_lang[78]}" ; then
		echo ""
		echo -e "${IYellow}${str_lang[79]}${NC}"
		check_if_in_VM
    	initialize_desktop_selection
	else
		echo -e "${IYellow}${str_lang[80]}${NC}"
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
				echo -e "${2:-"${IYellow}${str_lang[81]}${NC}"}";;
		esac
	done
}
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
echo -e "${NC}$slim"
num=0 

while IFS='' read -r line || [[ -n "$line" ]]; do
    num=$(( $num + 1 ))
    echo "["$num"]" $line
done < disks
echo -e "$slim"
read -rp "${str_lang[82]} " input

if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   	then
	echo -e "${IYellow}${str_lang[80]}${NC}"
	tput cnorm   -- normal  	# Εμφάνιση cursor
	exit 0
fi

if [ $input -gt 0 ] && [ $input -le $num ]; #έλεγχος αν το input είναι μέσα στο εύρος της λίστας
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
	echo -e "${IYellow}${str_lang[120]}${NC}"
	sleep 2
	clear
fi
done
rm disks

}
export -f diskchooser
################################################################
clear
setfont gr928a-8x16.psfu
language
#Τυπικός έλεγχος για το αν είσαι root. because you never know
if [ "$(id -u)" -ne 0 ] ; then
	echo -e "${IRed}${str_lang[84]}${NC}"
	echo -e "${IYellow}${str_lang[80]}${NC}"
	sleep 2
	exit 1
fi
#Τυπικός έλεγχος για το αν το τρέχει σε Arch.
if [ ! -f /etc/arch-release ] ; then
	echo -e "${IRed}${str_lang[85]}${NC}"
	echo -e "${IYellow}${str_lang[80]}${NC}"
	sleep 2
	exit
fi


echo -e "-------------------${IGreen} Archon  ver.4.0${NC}----------------------"
echo "     _____                                              ";
echo "  __|_    |__  _____   ______  __   _  _____  ____   _  ";
echo " |    \      ||     | |   ___||  |_| |/     \|    \ | | ";
echo " |     \     ||     \ |   |__ |   _  ||     ||     \| | ";
echo " |__|\__\  __||__|\__\|______||__| |_|\_____/|__/\____| ";
echo "    |_____|                                             ";
echo "                                                        ";
echo -e "${IYellow}         ${str_lang[86]}${NC}";
echo -e "$slim"
sleep 1
echo -e "${str_lang[87]}"
echo -e "${str_lang[88]}"
echo
echo -e "${str_lang[89]}"
echo
echo -e "${str_lang[90]}"
echo -e "${str_lang[91]}"
echo
echo -e "${IYellow}${str_lang[92]}${NC}"
echo -e "${IYellow}${str_lang[93]}${NC}"
echo
echo -e "${str_lang[94]}"
sleep 5
echo
if YN_Q "${str_lang[77]} " "${str_lang[78]}" ; then
	echo ""
	echo -e "${IYellow}${str_lang[79]}${NC}"
else
	echo -e "${IYellow}${str_lang[80]}${NC}"
	exit 0
fi
echo
sleep 1
echo -e "$slim"
echo -e "${IGreen}${str_lang[95]}${NC}"
echo -e "$slim"
if ping -c 3 www.google.com &> /dev/null; then
  echo -e "$slim"
  echo -e "${IYellow}${str_lang[96]}${NC}"
  echo -e "${str_lang[97]}"
  echo -e "$slim"
else
	echo -e "${IRed}${str_lang[98]}"
	echo -e "${IRed}${str_lang[99]}${NC}"
	sleep 1
	echo -e "${IYellow}${str_lang[81]}${NC}"
	sleep 1
	exit 1
fi
sleep 1
echo
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[100]}${NC}"
echo
echo -e "${IRed}${str_lang[101]}"
echo -e "${IRed}${str_lang[102]}"
echo -e "$slim"
echo
diskchooser
#lsblk | grep -i 'sd\|nvme' #Προσθήκη nvme ανάγνωσης στην εντολή lsblk
#echo
#echo
#echo -e "$slim"
#read -rp " Γράψτε σε ποιο δίσκο (με την μορφή /dev/sdX ή /dev/nvmeX) θα εγκατασταθεί το Arch; " diskvar
#echo -e "$slim"
echo
echo -e "$slim"
echo -e "${IYellow}${str_lang[103]} $diskvar ${NC}"
echo -e "$slim"
sleep 1
echo
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[104]}${NC}"
echo
echo "              ${str_lang[105]}"
echo -e "$slim"
sleep 1
set -e
################### Check if BIOS or UEFI #####################

function UEFI () {
if  [[ "$diskvar" = *"/dev/sd"[a-z]* ]]; then
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
        disknumber="p2"
		filesystems
        mkdir "/mnt/boot"
        mount "$diskvar""p1" "/mnt/boot"
        sleep 1
fi
}
function BIOS () {
	if [[ "$diskvar" = *"/dev/sd"[a-z]* ]]; then
		parted "$diskvar" mklabel msdos
		parted "$diskvar" mkpart primary ext4 1MiB 100%
		sleep 1
	else
		parted "$diskvar" mklabel msdos
		parted "$diskvar" mkpart primary ext4 1MiB 100% 
		sleep 1
	fi
}

if [ -d /sys/firmware/efi ]; then  #Η αρχική συνθήκη παραμένει ίδια
	echo
	echo -e "${IYellow}${str_lang[106]}${NC}";
	echo
	sleep 1
	UEFI   #Συνάρτηση για UEFI, αν προστεθεί sd? ή nvme? (line 311-333)
else
	echo
	echo -e "${IYellow}${str_lang[107]}${NC}";
	echo
	sleep 1
  #Συνάρτηση για BIOS, αν προστεθεί sd? ή nvme? (line 334-348)
					########## Υποστηριξη GPT για BIOS συστήματα ##########
	echo -e "${IYellow}${str_lang[108]}${NC}"
	echo
	PS3="${str_lang[109]} "
	options=("MBR" "GPT")
	select opt in "${options[@]}"
	do
		case $opt in
			"MBR")
				parted "$diskvar" mklabel msdos
				parted "$diskvar" mkpart primary ext4 1MiB 100%
				if [[ "$diskvar" = *"/dev/sd"[a-z]* ]]; then
					disknumber="1"
				else
					disknumber="p1"
				fi
				filesystems
				break
				;;
			"GPT")
				parted "$diskvar" mklabel gpt
				parted "$diskvar" mkpart primary 1 3
				parted "$diskvar" set 1 bios_grub on
				parted "$diskvar" mkpart primary ext4 3MiB 100%
				if [[ "$diskvar" = *"/dev/sd"[a-z]* ]]; then
					disknumber="2"
				else
					disknumber="p2"
				fi
				filesystems
				break
				;;
			*)
			    echo -e "${IRed}${str_lang[110]}"
			    echo -e "${IRed}${str_lang[111]}${NC}"
			    ;;
		esac
	done
fi
sleep 1
echo
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[112]}${NC}  "
echo -e "$slim"
pacman -Syy
#pacman -S --noconfirm reflector #απενεργοποίηση λόγω bug του Reflector
#reflector --latest 10 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
#pacman -Syy
sleep 1
echo
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[113]}${NC} "
echo -e "$slim"
echo -e "${IYellow}${str_lang[114]}${NC}"
echo -e "$slim"
sleep 2
pacstrap /mnt base base-devel linux linux-firmware dhcpcd "$fsprogs"
echo
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[115]}${NC}"
echo -e "$slim"
echo -e "${str_lang[116]}"
echo -e "$slim"
sleep 1
cp archon.sh /mnt/archon.sh
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./archon.sh --stage chroot
echo
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[117]}${NC}"
echo -e "${str_lang[118]}"
echo -e "$slim"
sleep 5
exit
