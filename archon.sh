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

##########	1. Variables 

#####	1.1 Color Variables
IRed='\033[0;91m'       # Red
IGreen='\033[0;92m'     # Green
IYellow='\033[0;93m'    # Yellow
#IBlue='\033[0;94m'     # Blue
#IPurple='\033[0;95m'   # Not used yet Purple
#ICyan='\033[0;96m'     # Not used yet Cyan
#IWhite='\033[0;97m'    # White
IBlack='\033[0;30m'     # Black
NC='\033[0m'
slim=$(printf '%0.s-' {1..56})  # Γραμμή περιγράμματος
# ########## Δημιουργία μενού διαθέσιμων γλωσσών ##########
function menu_languages {
    tput cup 10 40
	echo -e "${NC}$slim"
	tput cup 11 50
	echo -e "${IGreen}[1] Ελληνικά"
    tput cup 11 80
	echo -e "${IGreen}[2] English"
    tput cup 12 40
	echo -e "${NC}$slim"
}
#
# ########## Μενού επιλογής γλώσσας ##########
# Ανάλογα τις γλώσσες που θα έχουμε διαθέσιμες για την διαδικασία
#εγκατάστασης, θα έχουμε και τα αντίστοιχα αρχεία txt
function language {
    clear
    menu_languages
	while true; do
	    tput cup 13 64
		read -rn1 epilogi    # Εδώ ανάλογα με την επιλογή της
		case $epilogi in    # γλώσσας, δίνει σαν όνομα αρχείου
			[1] )           # να διαβάσει το αντίστοιχο .txt
                gr_color="${IYellow}"
                en_color="${IBlack}"
                cp lang_gr.txt lang.txt
				break
				;;
			[2] )
                gr_color="${IBlack}"
                en_color="${IYellow}"
                cp lang_en.txt lang.txt
				break
				;;
			* )
				clear
				menu_languages
				;;
		esac
	 done
	while IFS= read -r line; do # Διαβάζει γραμμή-γραμμή το txt
		str_lang+=("$line")     # αρχείο της επιλεγμένης γλώσσας
    done < "lang.txt"             # και γεμίζει τον πίνακα str_lang
    tput cup 11 50  # Εφέ επιλογής γλώσσας
	echo -e "${gr_color}[1] Ελληνικά"
    tput cup 11 80
	echo -e "${en_color}[2] English"
    echo -e "${NC}"
    echo
}

########## 2. Functions

##### 2.1 Filesystem Function
function filesystems(){ 
	PS3="${str_lang[0]} "
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
				if YN_Q "${str_lang[121]} " "${str_lang[78]}" ; then
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
			*)  echo -e "${NC}${str_lang[1]}\n${IRed}${str_lang[2]}${NC}"
			    ;;
			esac
        done
    }

##### 2.2 Check Virtual Machine Function
function check_if_in_VM() {
	installer "${str_lang[3]}" facter
    if [[ $(facter 2>/dev/null | grep 'is_virtual' | awk -F'=> ' '{print $2}') == true ]]; then
		echo
        installer "${IGreen}${str_lang[4]}${NC}" virtualbox-guest-dkms linux-headers xf86-video-vmware
    else
        echo
        echo -e "${IGreen}${str_lang[5]}${NC}"
		sleep 2
        pacman -Rs --noconfirm facter boost-libs cpp-hocon leatherman yaml-cpp
    fi
    sleep 2
}

##### 2.3 Installer Function 
function installer() {
	echo
    echo -e "${IGreen}$1 ...${NC}"
	sleep 2
    echo
	echo -e "${IYellow}${str_lang[122]} ${*:2} ${NC}" # Ενημέρωση του τι θα εγκατασταθεί
	sleep 2
    echo
    if pacman -S --noconfirm "${@:2}" # Με ${*2} διαβάζει τα input
    then
        echo
        echo -e "${IGreen}${str_lang[7]} $1 ...${NC}"
    else
        echo
        echo -e "${IRed}${str_lang[8]} $1 ...${NC}"
    fi

}

##### 2.4 Check for Net Connection Function (If it is off , exit immediately)
function check_net_connection() {
    sleep 1
    echo -e "$slim"
    echo -e "${IGreen}${str_lang[9]}${NC}"
    echo -e "$slim"
    if ping -c 3 www.google.com &> /dev/null; then
        echo
        echo -e "${IYellow}${str_lang[10]}\n${NC}"
    else
        echo
        echo -e "${IRed}${str_lang[11]}\n"
        echo -e "${str_lang[12]}\n${str_lang[13]}${NC}"
        echo
        exit 1
    fi
}

##### 2.5 Desktop Selection Function
function initialize_desktop_selection() {
	sleep 2
	echo
    installer "${str_lang[123]}" xorg xorg-server xorg-xinit alsa-utils alsa-firmware pulseaudio pulseaudio-alsa noto-fonts	# Εγκατάσταση Xorg Server και Audio server
    echo
    PS3="${str_lang[14]} "

	options=("GNOME" "Mate" "Deepin" "Xfce" "KDE" "LXQt" "Cinnamon" "Budgie" "i3" "Enlightenment" "UKUI" "Fluxbox" "Sugar" "Twm" "${str_lang[15]}")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")
                installer "${str_lang[6]} GNOME Desktop Enviroment" gnome gnome-extra
                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 		"Mate")
                installer "${str_lang[6]} Mate Desktop Environment" mate mate-extra networkmanager network-manager-applet
                installer "${str_lang[6]} LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Deepin")
                installer "${str_lang[6]} Deepin Desktop Environment" deepin deepin-extra networkmanager
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Xfce")
                installer "${str_lang[6]} Xfce Desktop Environment" xfce4 xfce4-goodies pavucontrol networkmanager network-manager-applet
                installer "${str_lang[6]} LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "KDE")
                installer "${str_lang[6]} KDE Desktop" plasma-meta konsole dolphin
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "LXQt")
                installer "${str_lang[6]} LXQt Desktop Environment" lxqt breeze-icons
                installer "${str_lang[6]} SDDM Display Manager" sddm                
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Cinnamon")
                installer "${str_lang[6]} Cinnamon Desktop Environment" cinnamon xterm networkmanager
                installer "${str_lang[6]} LightDM Display Manager" lightdm lightdm-gtk-greeter               
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Budgie")
                installer "${str_lang[6]} Budgie Desktop Environment" budgie-desktop budgie-extras xterm networkmanager network-manager-applet
                installer "${str_lang[6]} LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "i3")
                installer "${str_lang[6]} i3 Desktop Environment" i3 dmenu rxvt-unicode
                echo -e '#!/bin/bash \nexec i3' > /home/"$USER"/.xinitrc
                exit 0
                ;;
        "Enlightenment")
                installer "${str_lang[6]} Enlightenment Desktop Environment" enlightenment terminology connman acpid #acpid and iwd need investigation
                installer "${str_lang[6]} LightDM Display Manager" lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                sudo systemctl enable acpid
                sudo systemctl enable connman.service
                exit 0
                ;;
        "UKUI")
                installer "${str_lang[6]} UKUI Desktop Environment" ukui xterm networkmanager network-manager-applet
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Fluxbox")
                installer "${str_lang[6]} Fluxbox Desktop Environment" fluxbox xterm menumaker
                echo -e '#!/bin/bash \nstartfluxbox' > /home/"$USER"/.xinitrc
                exit 0
                ;;
        "Sugar")
                installer "${str_lang[6]} Sugar Desktop Environment" sugar sugar-fructose xterm
                installer "LXDM Display Manager" lxdm
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Twm")
                installer "${str_lang[6]} Twm Desktop Environment" xorg-twm xterm xorg-xclock
                exit 0
                ;;
		"${str_lang[15]}")
                echo -e "${IYellow}${str_lang[16]} ${USER}${NC}"
                exit 0
                ;;
            *)
                echo -e "${IRed}${str_lang[17]}\n${str_lang[18]}${NC}"
                ;;
        esac
	done
}

##### 2.6 Chroot Function 
function chroot_stage {
   	while IFS= read -r line; do # Διαβάζει γραμμή-γραμμή το txt
    	str_lang+=("$line")     # αρχείο της επιλεγμένης γλώσσας
    done < "lang.txt"           # και γεμίζει τον πίνακα str_lang
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
	{
		echo "127.0.0.1		localhost"
		echo "127.0.1.1		$hostvar.localdomain $hostvar"
		echo "::1			localhost"
	}> /etc/hosts
	echo
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
		echo
        echo -e "${IYellow}${str_lang[30]}${NC}"				# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		systemctl enable dhcpcd@"$ethernet".service
		echo
        echo -e "${IGreen}${str_lang[31]} $ethernet ${str_lang[32]}${NC}";
	fi
	wifi=$(ip link | grep ": "| grep -oE "(w\\w+)")			# Αναζήτηση κάρτας wifi
	if [ "$wifi" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα wifi
		echo
        echo -e "${IYellow}${str_lang[33]}${NC}"		# και αν υπάρχει γίνεται εγκατάσταση
	else 								# και ενεργοποίηση
		installer "${str_lang[125]}" iw wpa_supplicant dialog netctl wireless-regdb crda # CRDA/wireless-regdb : https://wiki.archlinux.org/index.php/Network_configuration/Wireless#Respecting_the_regulatory_domain
		systemctl enable netctl-auto@"$wifi".service
		echo
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
	#########################################################
	until passwd						# Μέχρι να είναι επιτυχής
	do						        	# η αλλαγή του κωδικού
	    echo							# του root χρήστη, θα
	    echo -e "${IYellow}${str_lang[39]}${NC}"	# τυπώνεται αυτό το μήνυμα
	    echo							#
	done							#
	#########################################################
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
		installer "${str_lang[125]}" linux-lts
	fi
	echo
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[45]}${NC}        "
	echo
	echo -e "${str_lang[46]}"
	echo -e "${str_lang[47]}"
	echo -e "$slim"
	echo
	sleep 2

	installer "${str_lang[126]}" grub efibootmgr os-prober
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
		    mount "$line" /run/media/disk$num && echo -e "${IYellow}${str_lang[48]} $num ${str_lang[49]}${NC}"
		    sleep 1
		done < "disks.txt"

		else
		    echo -e "${IRed}${str_lang[47]}${NC}"
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
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[51]}${NC}"
	echo
	echo -e "${str_lang[52]}"
	echo -e "${str_lang[53]}"
	echo
	echo -e "${str_lang[54]}"
	echo -e "${str_lang[55]}"
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
	echo -e "$slim"
	echo -e "${IGreen}${str_lang[62]}${NC}   "
	echo
	echo -e "${str_lang[63]}"
	echo -e "${str_lang[64]}"
	echo -e "${str_lang[65]}"
	echo -e "${str_lang[66]}"
	echo -e "$slim"
	sleep 2
	echo
	if YN_Q "${str_lang[127]} " "${str_lang[78]}" ; then
		echo
		read -rp "${str_lang[128]} " swap_size
		echo
        while :		# Δικλείδα ασφαλείας αν ο χρήστης προσθέσει μεγάλο νούμερο.
		do 
			if [ "$swap_size" -ge 512 ] && [ "$swap_size" -le 8192 ]; then
				break
			else
				read -rp "${str_lang[129]} " swap_size
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
    echo
	############# Installing Desktop ###########
	if YN_Q "${str_lang[77]} " "${str_lang[78]}" ; then
		echo
		echo -e "${IYellow}${str_lang[79]}${NC}"
		check_if_in_VM
    	initialize_desktop_selection
	else
        echo -e "$slim"
        echo -e "${IGreen}${str_lang[117]}${NC}"
        echo -e "${str_lang[118]}"
        echo -e "${str_lang[130]}"
        echo -e "${str_lang[131]}"
        echo -e "$slim"
        sleep 5
        exit
	fi
}

##### 2.7 Yes or no Function 
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

clear

##### 2.8 Test for chroot Function ()
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


##### 2.9 Diskchooser Function (Cases for avoid wrong entries)
function diskchooser() {

lsblk --noheadings --raw | grep disk | awk '{print $1}' > disks

while true
do
echo -e "$slim"
num=0 

while IFS='' read -r line || [[ -n "$line" ]]; do
    num=$(( num + 1 ))
    echo "[$num]" "$line"
done < disks
echo -e "$slim"
echo
read -rp "${str_lang[82]} " input

if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   	then
        echo
	    echo -e "${IYellow}${str_lang[80]}${NC}"
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
	echo -e "${IYellow}${str_lang[81]}${NC}"
	sleep 2
	clear
fi
done
rm disks

}

########## 3. Executable code

#Τυπικός έλεγχος για το αν είσαι root. because you never know
if [ "$(id -u)" -ne 0 ] ; then
	echo
    echo -e "${IRed}${str_lang[84]}${NC}"
	echo -e "${IYellow}${str_lang[80]}${NC}"
	echo
    sleep 2
	exit 1
fi
#Τυπικός έλεγχος για το αν το τρέχει σε Arch.
if [ ! -f /etc/arch-release ] ; then
	echo
    echo -e "${IRed}${str_lang[85]}${NC}"
	echo -e "${IYellow}${str_lang[80]}${NC}"
	echo
    sleep 2
	exit
fi

setfont gr928a-8x16.psfu
language
echo -e "----------------------${IGreen} Archon ${NC}--------------------------"
echo "     _____                                              ";
echo "  __|_    |__  _____   ______  __   _  _____  ____   _  ";
echo " |    \      ||     | |   ___||  |_| |/     \|    \ | | ";
echo " |     \     ||     \ |   |__ |   _  ||     ||     \| | ";
echo " |__|\__\  __||__|\__\|______||__| |_|\_____/|__/\____| ";
echo "    |_____|                                             ";
echo "                                                        ";
echo -e "${IYellow}         ${str_lang[86]}        ${NC}";
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
echo -e "${IYellow} ${str_lang[92]}${NC}"
echo -e "${IYellow} ${str_lang[93]}${NC}"
echo
echo -e "${str_lang[94]}"
sleep 5
echo
if YN_Q "${str_lang[77]} " "${str_lang[78]}" ; then
	echo
	echo -e "${IYellow}${str_lang[79]}${NC}"
else
    echo
	echo -e "${IYellow} ${str_lang[80]}${NC}"
	exit 0
fi
echo
sleep 1
echo -e "$slim"
echo -e "${IGreen}${str_lang[95]}${NC}"
echo -e "$slim"
if ping -c 3 www.google.com &> /dev/null; then
  echo
  echo -e "${IYellow}${str_lang[96]}${NC}"
  echo -e "${str_lang[97]}"
  echo
else
    echo
	echo -e "${IRed}${str_lang[98]}${NC}"
	echo -e "${str_lang[99]}"
	echo
    sleep 1
	echo -e "${IYellow} ${str_lang[80]}${NC}"
	echo
    sleep 1
	exit 1
fi
sleep 1
echo
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[100]}${NC}"
echo
echo -e "${str_lang[101]}"
echo -e "${str_lang[102]}"
echo -e "$slim"
echo
diskchooser
echo
echo -e "$slim"
echo -e "${IYellow}${str_lang[103]} $diskvar ${NC}"
echo -e "$slim"
sleep 1
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[104]}"
echo
echo -e "${str_lang[105]}${NC}"
echo -e "$slim"
sleep 1
set -e
################### Check if BIOS or UEFI #####################

if [ -d /sys/firmware/efi ]; then  #Η αρχική συνθήκη παραμένει ίδια
	echo
	echo -e "${IYellow}${str_lang[106]}${NC}";
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
	echo -e "${IYellow}${str_lang[107]}${NC}";
	echo
	sleep 1
	########## Υποστηριξη GPT για BIOS συστήματα ##########
	echo
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
			*)  echo -e "${IRed}${str_lang[110]}"
			    echo -e "${str_lang[111]}${NC}"
			    ;;
		esac
	done
fi

sleep 1
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[112]}${NC}  "
echo -e "$slim"
sleep 1
pacman -Syy
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[113]}${NC} "
echo
echo -e "${IYellow}${str_lang[114]}${NC}"
echo -e "$slim"
sleep 2
pacstrap /mnt base base-devel linux linux-firmware dhcpcd "$fsprogs"
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[115]}${NC}"
echo
echo -e "${str_lang[116]}"
echo -e "$slim"
sleep 1
##### Exported functions 
export -f diskchooser
##### Exported Variables
if [[ "$file_format" == "btrfs" ]]; then
	export file_format="$file_format"
	export diskvar="$diskvar"
	export disknumber="$disknumber"
	export diskletter="$diskletter"
fi

cp archon.sh /mnt/archon.sh
cp lang.txt /mnt/lang.txt
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./archon.sh --stage chroot
rm /mnt/archon.sh #διαγραφή του script από το / του συστήματος
echo
echo -e "$slim"
echo -e "${IGreen}${str_lang[117]}${NC}                    "
echo -e "${str_lang[118]}"
echo -e "$slim"
rm /mnt/lang.txt
rm /run/usb/Archon/lang.txt
sleep 5
exit
