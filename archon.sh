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
		read -n1 epilogi    # Εδώ ανάλογα με την επιλογή της
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
			esac
        done
    }

##### 2.2 Check Virtual Machine Function
function check_if_in_VM() {
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

	sleep 2
    echo
    if pacman -S --noconfirm "${@:2}" # Με ${*2} διαβάζει τα input
    then
        echo
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
        echo
        exit 1
    fi
}

##### 2.5 Desktop Selection Function
function initialize_desktop_selection() {
	sleep 2
	echo

	options=("GNOME" "Mate" "Deepin" "Xfce" "KDE" "LXQt" "Cinnamon" "Budgie" "i3" "Enlightenment" "UKUI" "Fluxbox" "Sugar" "Twm" "${str_lang[15]}")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")

                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 		"Mate")

                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Deepin")

                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Xfce")

                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "KDE")

                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "LXQt")

                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Cinnamon")

                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Budgie")

                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "i3")

                sudo systemctl enable lightdm
                sudo systemctl enable acpid
                sudo systemctl enable connman.service
                exit 0
                ;;
        "UKUI")

                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Fluxbox")

                echo -e '#!/bin/bash \nstartfluxbox' > /home/"$USER"/.xinitrc
                exit 0
                ;;
        "Sugar")

                installer "LXDM Display Manager" lxdm
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Twm")

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

	sleep 2
	ethernet=$(ip link | grep "2: "| grep -oE "(en\\w+)")		# Αναζήτηση κάρτας ethernet
	if [ "$ethernet" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα ethernet
		echo

	fi
	wifi=$(ip link | grep ": "| grep -oE "(w\\w+)")			# Αναζήτηση κάρτας wifi
	if [ "$wifi" = "" ]; then					# Έλεγχος αν υπάρχει κάρτα wifi
		echo

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

	echo
	echo -e "${str_lang[41]}"
	echo -e "${str_lang[42]}"
	echo -e "${str_lang[43]}"
	echo -e "$slim"
	sleep 2

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

		    sleep 1
		done < "disks.txt"

		else

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

		echo
        while :		# Δικλείδα ασφαλείας αν ο χρήστης προσθέσει μεγάλο νούμερο.
		do 
			if [ "$swap_size" -ge 512 ] && [ "$swap_size" -le 8192 ]; then
				break
			else

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


if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   	then
        echo

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

	echo
    sleep 2
	exit 1
fi
#Τυπικός έλεγχος για το αν το τρέχει σε Arch.
if [ ! -f /etc/arch-release ] ; then
	echo

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

	exit 0
fi
echo
sleep 1
echo -e "$slim"
echo -e "${IGreen}${str_lang[95]}${NC}"
echo -e "$slim"
if ping -c 3 www.google.com &> /dev/null; then
  echo

	echo
    sleep 1
	exit 1
fi
sleep 1
### Update the system clock
timedatectl set-ntp true
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

echo
echo -e "${IYellow}${str_lang[114]}${NC}"
echo -e "$slim"
sleep 2
pacstrap /mnt base base-devel linux linux-firmware dhcpcd "$fsprogs"
echo

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

sleep 5
exit
